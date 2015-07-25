#ifndef DCHAR_H
#define DCHAR_H

#if _MSC_VER
    #pragma warning (disable : 4514)
#endif

#undef TEXT

#if UNICODE

#include <string.h>
#include <wchar.h>

typedef wchar_t dchar;
#define TEXT(x)

#define Dchar_mbmax        1

struct Dchar {
    static dchar *inc(dchar *p) { return p + 1; }
    static dchar *dec(dchar *pstart, dchar *p) { (void)pstart; return p - 1; }
    static int len(const dchar *p) { return wcslen(p); }
    static dchar get(dchar *p) { return *p }
    static dchar getprev(dchar *pstart, dchar *p) { (void)pstart; return p[-1]; }
    static dchar *put(dchar *p, dchar c) { *p = c; return p + 1; }
    static int cmp(dchar *s1, dchar *s2) {
#if __DMC__
        if (!*s1 && !s2) {
            return 0;
        }
#endif
        return wcscmp(s1, s2);
#if 0
        return (*s1 == *s2) ? wcscmp(s1, s2) : ((int)*s1 - (int)*s2);
#endif
    }
    static int memcmp(const dchar *s1, const dchar *s2, int nchars) {
        return ::memchmp(s1, s2, nchars * sizeof(dchar));
    }
    static int isDigit(dchar c) { return '0' <= c && c <= '9' }
    static int isAlpha(dchar c) { return iswalpha(c); }
    static int isUpper(dchar c) { return iswupper(c); }
    static int isLower(dchar c) { return iswlower(c); }
    static int isLocaleUpper(dchar c) {return isUpper(c); }
    static int isLocaleLower(dchar c) {return isLower(c); }
    static int toLower(dchar c) { return isUpper(c) ? towlower(c) : c; }
    static int toLower(dchar *p) { return toLower(*p); }
    static int toUpper(dchar c) { return isLower(c) ? towupper(c) : c; }
    static dchar *dup(dchar *p) { return ::_wcsdup(p); }	// BUG: out of memory?
    static dchar *dup(char *p);static dchar *chr(dchar *p, unsigned c) { return wcschr(p, (dchar)c); }
    static dchar *rchr(dchar *p, unsigned c) { return wcsrchr(p, (dchar)c); }
    static dchar *memchr(dchar *p, int c, int count);
    static dchar *cpy(dchar *s1, dchar *s2) { return wcscpy(s1, s2); }
    static dchar *str(dchar *s1, dchar *s2) { return wcsstr(s1, s2); }
    static unsigned calcHash(const dchar *str, unsigned len);

    // Case insensitive versions
    static int icmp(dchar *s1, dchar *s2) { return wcsicmp(s1, s2); }
    static int memicmp(const dchar *s1, const dchar *s2, int nchars) { return ::wcsnicmp(s1, s2, nchars); }
    static unsigned icalcHash(const dchar *str, unsigned len);
};

#elif MCBS

#include <limits.h>
#include <mbstring.h>

typedef char dchar;
#define TEXT(x)		x

#define Dchar_mbmax	MB_LEN_MAX

#elif UTF8

typedef char dchar;
#define TEXT(x)		x

#define Dchar_mbmax	6

struct Dchar
{
    static char mblen[256];

    static dchar *inc(dchar *p) { return p + mblen[*p & 0xFF]; }
    static dchar *dec(dchar *pstart, dchar *p);
    static int len(const dchar *p) { return strlen(p); }
    static int get(dchar *p);
    static int getprev(dchar *pstart, dchar *p)
	{ return *dec(pstart, p) & 0xFF; }
    static dchar *put(dchar *p, unsigned c);
    static int cmp(dchar *s1, dchar *s2) { return strcmp(s1, s2); }
    static int memcmp(const dchar *s1, const dchar *s2, int nchars) { return ::memcmp(s1, s2, nchars); }
    static int isDigit(dchar c) { return '0' <= c && c <= '9'; }
    static int isAlpha(dchar c) { return c <= 0x7F ? isalpha(c) : 0; }
    static int isUpper(dchar c) { return c <= 0x7F ? isupper(c) : 0; }
    static int isLower(dchar c) { return c <= 0x7F ? islower(c) : 0; }
    static int isLocaleUpper(dchar c) { return isUpper(c); }
    static int isLocaleLower(dchar c) { return isLower(c); }
    static int toLower(dchar c) { return isUpper(c) ? tolower(c) : c; }
    static int toLower(dchar *p) { return toLower(*p); }
    static int toUpper(dchar c) { return isLower(c) ? toupper(c) : c; }
    static dchar *dup(dchar *p) { return ::strdup(p); }	// BUG: out of memory?
    static dchar *chr(dchar *p, int c) { return strchr(p, c); }
    static dchar *rchr(dchar *p, int c) { return strrchr(p, c); }
    static dchar *memchr(dchar *p, int c, int count)
	{ return (dchar *)::memchr(p, c, count); }
    static dchar *cpy(dchar *s1, dchar *s2) { return strcpy(s1, s2); }
    static dchar *str(dchar *s1, dchar *s2) { return strstr(s1, s2); }
    static unsigned calcHash(const dchar *str, unsigned len);

    // Case insensitive versions
    static int icmp(dchar *s1, dchar *s2) { return _mbsicmp(s1, s2); }
    static int memicmp(const dchar *s1, const dchar *s2, int nchars) { return ::_mbsnicmp(s1, s2, nchars); }
};

#else

#include <string.h>
#include <ctype.h>

typedef char dchar;
#define TEXT(x)		x

#define Dchar_mbmax	1

struct Dchar
{
    static dchar *inc(dchar *p) { return p + 1; }
    static dchar *dec(dchar *pstart, dchar *p) { return p - 1; }
    static int len(const dchar *p) { return strlen(p); }
    static int get(dchar *p) { return *p & 0xFF; }
    static int getprev(dchar *pstart, dchar *p) { return p[-1] & 0xFF; }
    static dchar *put(dchar *p, unsigned c) { *p = c; return p + 1; }
    static int cmp(dchar *s1, dchar *s2) { return strcmp(s1, s2); }
    static int memcmp(const dchar *s1, const dchar *s2, int nchars) { return ::memcmp(s1, s2, nchars); }
    static int isDigit(dchar c) { return '0' <= c && c <= '9'; }
    static int isAlpha(dchar c) { return isalpha(c); }
    static int isUpper(dchar c) { return isupper(c); }
    static int isLower(dchar c) { return islower(c); }
    static int isLocaleUpper(dchar c) { return isupper(c); }
    static int isLocaleLower(dchar c) { return islower(c); }
    static int toLower(dchar c) { return isupper(c) ? tolower(c) : c; }
    static int toLower(dchar *p) { return toLower(*p); }
    static int toUpper(dchar c) { return islower(c) ? toupper(c) : c; }
    static dchar *dup(dchar *p) { return ::strdup(p); }	// BUG: out of memory?
    static dchar *chr(dchar *p, int c) { return strchr(p, c); }
    static dchar *rchr(dchar *p, int c) { return strrchr(p, c); }
    static dchar *memchr(dchar *p, int c, int count)
	{ return (dchar *)::memchr(p, c, count); }
    static dchar *cpy(dchar *s1, dchar *s2) { return strcpy(s1, s2); }
    static dchar *str(dchar *s1, dchar *s2) { return strstr(s1, s2); }
    static unsigned calcHash(const dchar *str, unsigned len);

    // Case insensitive versions
    static int icmp(dchar *s1, dchar *s2) { return stricmp(s1, s2); }
    static int memicmp(const dchar *s1, const dchar *s2, int nchars) { return ::memicmp(s1, s2, nchars); }
    static unsigned icalcHash(const dchar *str, unsigned len);
};

#endif
#endif
