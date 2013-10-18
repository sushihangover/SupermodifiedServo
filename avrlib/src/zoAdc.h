//****************************************************************************************
///	File Name	: \file zoAdc.h 
///	Description	: \brief Analog to digital converter peripheral function library.
//	Created		: 21/01/2010
//	Target MCU	: Mega 48/88/168/328
//	Author		: Sissakis Giannis
//  email		: info@01mech.com
//
//  Copyright (C) 2010 Zero One Mechatronics LP
//
//  This program is free software: you can redistribute it and/or modify it under the 
//  terms of the GNU General Public License as published by the Free Software Foundation, 
//  version 3 of the License or any later version. This program is distributed in the hope
//  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of 
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public 
//  License for more details: <http://www.gnu.org/licenses/>
//  
/// \ingroup driver_avr 
/// \defgroup zoAdc zoAdc.h : Avr ADC peripheral function library.
/// 
/// \par Overview
/// The ADC library provides functionality for the ADC peripheral module of an AVR 
/// processor.
///   
/// \par Usage example: Free running mode. 
/// \code
/// #include "zoAdc.h"
/// #include "zoTypes.h"
///
/// int main(void)
/// {
/// 	u16 adcResultChannel0,adcResultChannel3;
/// 	zoAdcInit();											//initialize ADC
/// 	zoAdcChannelEnable(ZO_ADC_CHANNEL_0);					//enable ADC0
/// 	zoAdcChannelEnable(ZO_ADC_CHANNEL_3);					//enable ADC3
///
/// 	while(1)
/// 	{
/// 		adcResultChannel0 = zoAdcRead(ZO_ADC_CHANNEL_0);	//read ADC0
/// 		adcResultChannel3 = zoAdcRead(ZO_ADC_CHANNEL_3);	//read ADC3
/// 	}
/// }
/// \endcode 
/// \par Usage example: Single conversion.
/// \code
/// #include "zoAdc.h"
/// #include "zoTypes.h"
///
/// int main(void)
/// {
/// 	u16 adcResultChannel0;
/// 	zoAdcInit();											//initialize ADC
/// 	zoAdcSetTrigger(ZO_ADC_TRIGGER_SINGLE_CONVERSION);		//configure single 
/// 															//conversion
/// 	zoAdcChannelEnable(ZO_ADC_CHANNEL_0);					//enable ADC0
///
/// 	while(1)
/// 	{
/// 		zoAdcStartConversion(ZO_ADC_CHANNEL_0);				//start conversion 
/// 		while(!zoAdcConversionCompleted());					//wait for adc to finish
/// 		adcResultChannel0 = zoAdcRead(ZO_ADC_CHANNEL_0);	//read ADC0 result
/// 	}
/// }
/// \endcode 
//****************************************************************************************
//@{

#ifndef ZO_ADC_H
#define ZO_ADC_H

#include "zoTypes.h"

///Prescaler configuration enumeration. Use one of the enumeration values as an argument 
///to the zoAdcSetPrescaler() function
typedef enum {
	ZO_ADC_PRESCALE_2=0x00,			///<adcClock = SystemClock / 2
	ZO_ADC_PRESCALE_4=0x02,			///<adcClock = SystemClock / 4
	ZO_ADC_PRESCALE_8,				///<adcClock = SystemClock / 8
	ZO_ADC_PRESCALE_16,				///<adcClock = SystemClock / 16
	ZO_ADC_PRESCALE_32,				///<adcClock = SystemClock / 32
	ZO_ADC_PRESCALE_64,				///<adcClock = SystemClock / 64
	ZO_ADC_PRESCALE_128				///<adcClock = SystemClock / 128
}ZO_ADC_PRESCALE;

///Adc reference configuration enumeration. Use one of the enumeration values as an 
///argument to the zoAdcSetReference() function
typedef enum {
	ZO_ADC_REFERENCE_AREF=0x00,		///< Select the AREF pin as the ADC voltage reference
	ZO_ADC_REFERENCE_AVCC=0x40,		///< Select the AVcc pin as the ADC voltage reference
	ZO_ADC_REFERENCE_1V1=0xC0,		///< Select the internal bandgap voltage as the ADC voltage reference
}ZO_ADC_REFERENCE;

///Adc trigger configuration enumeration. Use one of the enumeration values as an 
///argument to the zoAdcSetTrigger() function
typedef enum {
	ZO_ADC_TRIGGER_FREE_RUNNING=0x00,		///<The end of a conversion triggers the next conversion
	ZO_ADC_TRIGGER_ANALOG_COMPARATOR,		///<An analog comparator event triggers the next conversion
	ZO_ADC_TRIGGER_EXTINT_0,				///<An external interrupt triggers the next conversion
	ZO_ADC_TRIGGER_TIMER0_COMPARE_MATCH_A,	///<A compare match A on timer 0 triggers the next conversion
	ZO_ADC_TRIGGER_TIMER0_OVFL,				///<A timer o overflow triggers the next conversion
	ZO_ADC_TRIGGER_TIMER1_COMPARE_MATCH_B,	///<A compare match B on timer 1 triggers the next conversion
	ZO_ADC_TRIGGER_TIMER1_OVFL,				///<An 
	ZO_ADC_TRIGGER_TIMER1_ICP,				///<
	ZO_ADC_TRIGGER_SINGLE_CONVERSION		///<
}ZO_ADC_TRIGGER;

///Adc trigger configuration enumeration. Use one of the enumeration values as an 
///argument to the zoAdcChannelEnable(), zoAdcChannelDisable(), zoAdcStartConversion(), 
///zoAdcRead() functions
typedef enum {
	ZO_ADC_CHANNEL_0=0,
	ZO_ADC_CHANNEL_1,
	ZO_ADC_CHANNEL_2,
	ZO_ADC_CHANNEL_3,
	ZO_ADC_CHANNEL_4,
	ZO_ADC_CHANNEL_5,
	ZO_ADC_CHANNEL_6,
	ZO_ADC_CHANNEL_7,
	ZO_ADC_CHANNEL_TEMPERATURE,
	ZO_ADC_CHANNEL_1V1,
	ZO_ADC_CHANNEL_GND
}ZO_ADC_CHANNEL;

//Defaults________________________________________________________________________________
///Default trigger source for the ADC
#define ZO_ADC_DEFAULT_TRIGGER		ZO_ADC_TRIGGER_FREE_RUNNING
///Default prescaler of the ADC clock (AdcClock = SystemClock/AdcPrescaler)
#define ZO_ADC_DEFAULT_PRESCALER	ZO_ADC_PRESCALE_128
///Default voltage reference for the ADC
#define ZO_ADC_DEFAULT_REFERENCE	ZO_ADC_REFERENCE_AVCC

/*! \brief Initializes the ADC peripheral. Always call this function prior to any other 
	in this library file. */
void zoAdcInit(void);

/*! \brief Enables an ADC channel for conversion. This function can be called multiple
	times in user code in order to enable all desired ADC channels.
	\param channel The ADC channel to enable. */
void zoAdcChannelEnable(ZO_ADC_CHANNEL channel);

/*! \brief Reads the voltage present at the specified ADC channel.
	\param channel The ADC channel to sample.Choose on of the ZO_ADC_CHANNEL enumeration
	values
	\return The 10-bit value that was produced by the analog to digital conversion. */
u16  zoAdcRead(ZO_ADC_CHANNEL channel);

/*! \brief Configures the ADC clock prescaler. The ADC clock frequency is produced by 
	dividing the system clock frequency with the prescaler value: 
	AdcClockHz = SystemClockHz/AdcPrescaler.
	\param prescale The prescale value. Choose one of the ZO_ADC_PRESCALE enumeration 
	values */
void zoAdcSetPrescaler(ZO_ADC_PRESCALE prescale);

/*! \brief Configures the ADC voltage reference source. 
	\param ref The ADC voltage reference. Choose one of the ZO_ADC_REFERENCE enumeration 
	values */
void zoAdcSetReference(ZO_ADC_REFERENCE ref);

/*! \brief Configures the ADC start conversion trigger condition. All trigger conditions
	except the ZO_ADC_TRIGGER_SINGLE_CONVERSION enable the ADC auto trigger mode: ie 
	when the trigger condition is detected an ADC conversion will be automatically 
	triggered by the hardware. There is no need to issue a zoAdcStartConversion() at any 
	time when this kind of ADC triggering is used. In ZO_ADC_TRIGGER_FREE_RUNNING mode
	the end of the last conversion triggers the start of the next ADC conversion: ie the
	ADC is constantly sampling and converting the ADC inputs.
	\param trig The ADC triggering condition. Choose one of the ZO_ADC_TRIGGER enumeration 
	values */
void zoAdcSetTrigger(ZO_ADC_TRIGGER trig);

/*! \brief Disables an ADC channel for conversion. This function can be called multiple
	times in user code. If all channels are disabled used this function, the ADC ISR is
	also disabled.
	\param channel The ADC channel to disable. */
void zoAdcChannelDisable(ZO_ADC_CHANNEL channel);

/*! \brief Starts a conversion. This function should be used with the 
	ZO_ADC_TRIGGER_SINGLE_CONVERSION ADC triggering scheme.
	\param channel The ADC channel to sample. */
void zoAdcStartConversion(ZO_ADC_CHANNEL channel);

/*! \brief Starts a conversion. This function should be used with the 
	ZO_ADC_TRIGGER_SINGLE_CONVERSION ADC triggering scheme.
	\param channel The ADC channel to sample. */

bool zoAdcConversionCompleted(void);

/*! \brief Disable and turn off ADC completely. Power to the ADC peripheral is also
	disabled. */
void zoAdcOff(void);

#endif	//ZO_ADC_H
//@}
