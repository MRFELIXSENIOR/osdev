#ifndef __HPORT__
#define __HPORT__

unsigned char HPORT_GETBYTE(unsigned short port);
void HPORT_SENDBYTE(unsigned short port, unsigned char data);
unsigned short HPORT_GETWORD(unsigned short port);
void HPORT_SENDWORD(unsigned short port, unsigned short data);

#endif
