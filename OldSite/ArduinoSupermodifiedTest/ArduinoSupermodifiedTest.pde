#include <Wire.h>

// test for the supermodified



#define I2C_ADRESS_ME 0x01
#define I2C_ADRESS_SUPERMODIFIED 0x04


enum {
/*00*/	ZO_COMMAND_SET_GAIN_P = 0x00,
/*01*/	ZO_COMMAND_SET_GAIN_I,
/*02*/	ZO_COMMAND_SET_GAIN_D,
/*03*/	ZO_COMMAND_SET_PROFILE_ACCELERATION,
/*04*/	ZO_COMMAND_SET_PROFILE_VELOCITY,
/*05*/	ZO_COMMAND_SET_CURRENT_LIMIT,
/*06*/	ZO_COMMAND_SET_CURRENT_LIMIT_DURATION,
/*07*/	ZO_COMMAND_VELOCITY_MOVE,
/*08*/	ZO_COMMAND_ABSOLUTE_POSITION_MOVE,
/*09*/	ZO_COMMAND_RELATIVE_POSITION_MOVE,
/*0A*/  ZO_COMMAND_PROFILED_VELOCITY_MOVE,
/*0B*/  ZO_COMMAND_PROFILED_ABSOLUTE_POSITION_MOVE,
/*0C*/	ZO_COMMAND_PROFILED_RELATIVE_POSITION_MOVE,
/*0D*/	ZO_COMMAND_SET_VELOCITY_SETPOINT,
/*1E*/	ZO_COMMAND_SET_ABSOLUTE_POSITION_SETPOINT,
/*1F*/	ZO_COMMAND_SET_RELATIVE_POSITION_SETPOINT,
/*10*/	ZO_COMMAND_SET_PROFILED_VELOCITY_SETPOINT,
/*11*/	ZO_COMMAND_SET_PROFILED_ABSOLUTE_POSITION_SETPOINT,
/*12*/	ZO_COMMAND_SET_PROFILED_RELATIVE_POSITION_SETPOINT,
/*13*/	ZO_COMMAND_CONFIGURE_DIGITAL_IO,
/*14*/	ZO_COMMAND_SET_DIGITAL_OUT,
/*15*/	ZO_COMMAND_SET_NODE_ID,
/*16*/  ZO_COMMAND_SET_LOCAL_ACCEPTANCE_MASK,
/*17*/  ZO_COMMAND_SET_BAUD_UART,
/*18*/	ZO_COMMAND_RESET_POSITION,
/*19*/	ZO_COMMAND_START,
/*1A*/	ZO_COMMAND_HALT,
/*1B*/	ZO_COMMAND_STOP,
/*1C*/  ZO_COMMAND_SET_ERROR_REPORTING_LEVEL,
/*1D*/	ZO_COMMAND_SET_COMMANDS_END
};
enum {
/*64*/	ZO_COMMAND_GET_GAIN_P = 0x64,
/*65*/	ZO_COMMAND_GET_GAIN_I,
/*66*/	ZO_COMMAND_GET_GAIN_D,
/*67*/	ZO_COMMAND_GET_PROFILE_ACCELERATION,
/*68*/	ZO_COMMAND_GET_PROFILE_VELOCITY,
/*69*/	ZO_COMMAND_GET_CURRENT_LIMIT,
/*6A*/	ZO_COMMAND_GET_CURRENT_LIMIT_DURATION,
/*6B*/	ZO_COMMAND_GET_DIO_CONFIGURATION,
/*6C*/	ZO_COMMAND_GET_LOCAL_ACCEPTANCE_MASK,
/*6D*/	ZO_COMMAND_GET_DIGITAL_IN,
/*6E*/  ZO_COMMAND_GET_ANALOG_IN,
/*6F*/  ZO_COMMAND_GET_POSITION,
/*70*/	ZO_COMMAND_GET_ABSOLUTE_POSITION,
/*71*/	ZO_COMMAND_GET_VELOCITY,
/*72*/	ZO_COMMAND_GET_CURRENT,
/*73*/	ZO_COMMAND_GET_WARNING,
/*74*/	ZO_COMMANDS_GET_COMMANDS_END
};
//-----------------------------------------------------------
//                       supremodified
//-----------------------------------------------------------

 
unsigned char zoProtocolLRC(unsigned char *lrcBytes, unsigned char lrcByteCount){
  unsigned char lrc = 0; 
 
  for(unsigned char i=0; i<lrcByteCount; i++){ 
    lrc ^= lrcBytes[i]; 
  }
  return lrc; 
}


volatile bool waiting_for_answer = false;
unsigned long wait_start = 0;
unsigned long wait_timeout = 0;

void wait_for_answer(){
  waiting_for_answer = true;
  wait_start = micros();
  wait_timeout = wait_start+100000;
  while(waiting_for_answer){
    delayMicroseconds(2);
    if(wait_timeout<micros()){
      Serial.println("T");
      waiting_for_answer = false;
    }  
  }
  unsigned long wait_end = micros();
  //Serial.print("delay us ");
  //Serial.println( wait_end-wait_start );
}

//I2C protocol ommits the header and adressed ID:
//   <ownID> <commandID> <data byte count> <data1> <data2> ... <dataN> <lrc>

void send_cmd(unsigned char addr, unsigned char cmd, unsigned char* data, unsigned char nb_data){
  unsigned char lrc = zoProtocolLRC(data, nb_data);
  lrc ^= cmd;
  lrc ^= nb_data;
  
  unsigned char plop[nb_data + 5];
  plop[0] = addr;
  plop[1] = I2C_ADRESS_ME;
  plop[2] = cmd;
  plop[3] = nb_data;
  for(int i = 0; i<nb_data; i++){
    plop[4+i] = data[i];
  }
  plop[nb_data+4] = lrc;
  
  
  Wire.beginTransmission(addr); // transmit to device
  /*
  Wire.send(addr);              // adressed Node ID
  Wire.send(I2C_ADRESS_ME);     // own Node ID
  Wire.send(cmd);               // command ID
  Wire.send(nb_data);           // data byte count
  Wire.send(data, nb_data);     // data
  Wire.send(lrc);               // checksum
  */
  Wire.send(plop, nb_data+5);
  Wire.endTransmission();       // stop transmitting
  wait_for_answer();
  // TODO listen for the answer : <nodeID> <command> < 0 (byte data count)> <lrc>
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int nb_received)
{
  
  Wire.receive(); // adressed
  Wire.receive(); // own
  unsigned char cmd = Wire.receive();
  switch(cmd){
      case ZO_COMMAND_GET_ABSOLUTE_POSITION:
        {
        Wire.receive(); // count
        Serial.print("abs_pos = ");
        int pos = Wire.receive();
        pos |= (Wire.receive()<<8);
        Serial.println(pos);
        break;
        }
      case ZO_COMMAND_GET_POSITION:
        {
        Wire.receive(); // count
        unsigned char a = Wire.receive();
        unsigned char b = Wire.receive();
        unsigned char c = Wire.receive();
        unsigned char d = Wire.receive();
        
        int val = ((int)d<<24) | ((int)c<<16) | ((int)b<<8) | (int)a;
        
        Serial.print("pos = ");
        Serial.print(a, HEX);
        Serial.print(" ");
        Serial.print(b, HEX);
        Serial.print(" ");
        Serial.print(c, HEX);
        Serial.print(" ");
        Serial.print(d, HEX);
        Serial.print(" = ");
        Serial.println(val, HEX);
        }
        break;
      case 0xFA://error
        {
        int nb_err = Wire.receive(); // count
        Serial.println("Error : ");
        for(int i = 0; i<nb_err; i++){
          Serial.print(Wire.receive(),HEX);
          Serial.print(" ");
        }
        Serial.println(" ");
        }
        break;
    default:
      {
      break;
      Serial.print("nb_received = ");
      Serial.println(nb_received);
      unsigned char c;
      for(int i = 0; i<nb_received; i++){
        c =   Wire.receive();
        Serial.println(c, HEX);
        // TODO verify
      }
      }
      break;
    }
  while(Wire.available()){
    Wire.receive();
  }
  waiting_for_answer = false;
  
}






// -------------------------------------------------------



void start_supermodified(){
  send_cmd(I2C_ADRESS_SUPERMODIFIED, ZO_COMMAND_START, 0, 0);
}

#define NB_DATA 4
void  move1(){
  unsigned char data[NB_DATA];
  int nb_data = NB_DATA;
  
  // 0x000000FF
  data[0] = 0x00;
  data[1] = 0x10;
  data[2] = 0x00;
  data[3] = 0x00;
  
  send_cmd(I2C_ADRESS_SUPERMODIFIED, ZO_COMMAND_RELATIVE_POSITION_MOVE,  data, nb_data);
}


void reset_pos(){
  send_cmd(I2C_ADRESS_SUPERMODIFIED, ZO_COMMAND_RESET_POSITION, 0, 0);
}

void request_pos(){
  send_cmd(I2C_ADRESS_SUPERMODIFIED, ZO_COMMAND_GET_POSITION, 0, 0);
}
void request_abs_pos(){
  send_cmd(I2C_ADRESS_SUPERMODIFIED, ZO_COMMAND_GET_ABSOLUTE_POSITION, 0, 0);
}

void setup()
{
  Wire.begin(I2C_ADRESS_ME);                // join i2c bus
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(115200);           // start serial for output
  Serial.println("start");
  
  start_supermodified();
  //reset_pos();
  
  delay(100);
}

void loop()
{
  move1();
  delay(2000);
  request_abs_pos();
  //request_pos();
  delay(1000);
//  request_abs_pos();
}
