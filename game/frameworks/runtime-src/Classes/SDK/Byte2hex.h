// ConsoleApplication1.cpp : 定义控制台应用程序的入口点。
//
#include <ctype.h>

static char hexDigit[16] = { '0', '1', '2', '3', '4', '5', '6', '7',
'8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

static unsigned char hDigit2byte(int hex)
{
	switch (hex)	{
	case '0': return(0x0);
	case '1': return(0x1);
	case '2': return(0x2);
	case '3': return(0x3);
	case '4': return(0x4);
	case '5': return(0x5);
	case '6': return(0x6);
	case '7': return(0x7);
	case '8': return(0x8);
	case '9': return(0x9);
	case 'A': return(0xA);
	case 'B': return(0xB);
	case 'C': return(0xC);
	case 'D': return(0xD);
	case 'E': return(0xE);
	case 'F': return(0xF);
	default:  return(0);
	}
}

int byte2hex(const unsigned char *data, size_t size, char *outStr, size_t outSize)
{
	size_t	i;
	char	*p;

	if (outSize < 2 * size + 1)
		return(-1);

	p = outStr;
	for (i = 0; i < size; i++)	{
		*p++ = hexDigit[(*data) >> 4];
		*p++ = hexDigit[(*data) & 0x0f];
		data++;
	}
	*p = 0;
	return(p - outStr);
}


int hex2byte(const char *hexStr, unsigned char *outData, size_t outSize)
{
	size_t		len = 0;
	const char	*inStr = hexStr;
	unsigned char	*data = outData;

	if (outSize == 0)
		return -1;
	else
		*outData = 0;

	for (inStr = hexStr, len = 0; *inStr; inStr++)	{
		if (isxdigit(*inStr))
			len++;
		else if (!isspace(*inStr))
			return -2;
	}

	if (len > outSize * 2)
		return(-1);

	while (*hexStr)	{
		if (isxdigit(*hexStr))	{
			if (len % 2)	{
				*data |= hDigit2byte(toupper(*hexStr));
				data++;
			}
			else
				*data = (unsigned char)(hDigit2byte(toupper(*hexStr)) << 4);
			len--;
		}
		hexStr++;
	}
	return(data - outData);
}

/*
int main()
{
	unsigned char data[8] = { 65, 66, 67, 68, 69, 70, 71, 72 };
	 char* hex = new  char [17];//返回8*2=16
	 int hexlen = byte2hex(data, 8, hex, 17);
	 hex[hexlen] = 0;
	 printf(hex);

	 unsigned char* hexdata = new unsigned char[9];
	 int datalen =hex2byte(hex, hexdata, 9);
	 hexdata[datalen] = 0;
}*/
/** @} *//* hex2byte */
