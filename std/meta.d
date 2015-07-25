module std.meta;

template AliasSeq(TList...)
{
    alias AliasSeq = TList;
}

unittest
{
    import std.meta;
    alias TL = AliasSeq!(int, double);

    int foo(TL td)
    {
        return td[0] + cast(int)td[1];
    }
}

unittest
{
    alias TL = AliasSeq!(int, double);

    alias Types = AliasSeq!(TL, char);
    static assert(is(Types == AliasSeq!(int, double, char)));
}

private template genericIndexOf(args...)
    if(args.length >= 1)
{
    alias e = Alias!(args[0]);
    alias tuple = args[1 .. $];

    static if(tuple.length)
    {
        alias head = Alias!(tuple[0]);
        alias tail = tuple[1 .. $];

        static if(isSame!(e, head))
        {
            enum index = 0;
        }
        else
        {
            enum next = genericIndexOf!(e, tail).index;
            enum index = (next == -1) ? -1 : 1 + next;
        }
    }
    else
    {
        enum index = -1;
    }
}

unittest
{
    static assert(staticIndexOf!( byte, byte, short, int, long) ==  0);
    static assert(staticIndexOf!(short, byte, short, int, long) ==  1);
    static assert(staticIndexOf!(  int, byte, short, int, long) ==  2);
    static assert(staticIndexOf!( long, byte, short, int, long) ==  3);
    static assert(staticIndexOf!( char, byte, short, int, long) == -1);
    static assert(staticIndexOf!(   -1, byte, short, int, long) == -1);
    static assert(staticIndexOf!(void) == -1);

    static assert(staticIndexOf!("abc", "abc", "def", "ghi", "jkl") ==  0);
    static assert(staticIndexOf!("def", "abc", "def", "ghi", "jkl") ==  1);
    static assert(staticIndexOf!("ghi", "abc", "def", "ghi", "jkl") ==  2);
    static assert(staticIndexOf!("jkl", "abc", "def", "ghi", "jkl") ==  3);
    static assert(staticIndexOf!("mno", "abc", "def", "ghi", "jkl") == -1);
    static assert(staticIndexOf!( void, "abc", "def", "ghi", "jkl") == -1);
    static assert(staticIndexOf!(42) == -1);

    static assert(staticIndexOf!(void, 0, "void", void) == 2);
    static assert(staticIndexOf!("void", 0, void, "void") == 2);
}

alias IndexOf = staticIndexOf;

template staticIndexOf(T, TList...)
{
    enum staticIndexOf = genericIndexOf!(T, TList).index;
}

template staticIndexOf(alias T, TList...)
{
    enum staticIndexOf = genericIndexOf!(T, TList).index;
}

unittest
{
    import std.stdio;

    void foo()
    {
	       writeln("The index of long is $s", staticIndexOf!(long, AliasSeq!(int, long, double)));
    }
}

template Erase(T, TList...)
{
    alias Erase = GenericErase!(T, TList).result;
}

template Erase(alias T, TList...)
{
    alias Erase = GenericErase!(T, TList).result;
}

unittest
{
    alias Types = AliasSeq!(int, long, double, char);
    alias TL = Erase!(long, Types);
    static assert(is(TL == AliasSeq!(int, double, char)));
}

private template GenericErase(args...)
    if(args.length >= 1)
{
    alias e = Alias!(args[0]);
    alias tuple = args[1 .. $];

    static if (tuple.length)
    {
        alias head = Alias!(tuple[0]);
        alias tail = tuple[1 .. $];

        static if (isSame!(e, head))
            alias result = tail;
        else
            alias result = AliasSeq!(head, GenericErase!(e, tail).result);
    }
    else
    {
        alias result = AliasSeq!();
    }
}

unittest
{
    static assert(Pack!(Erase!(int, short, int, int, 4)).equals!(short, int, 4));
    static assert(Pack!(Erase!(1, real, 3, 1, 4, 1, 5, 9)).equals!(real, 3, 4, 1, 5,9));
}

template EraseAll(T, TList...)
{
    alias EraseAll = GenericEraseAll!(T, TList).result;
}

template EraseAll(alias T, TList...)
{
    alias EraseAll = GenericEraseAll!(T, TList).result;
}

unittest
{
    alias Types = AliasSeq!(int, long, long, int);

    alias TL = EraseAll!(long, Types);
    static assert(is(TL == AliasSeq!(int, int)));
}

private template GenericEraseAll(args...)
    if (args.length >= 1)
{
    alias e = Alias!(args[0]);
    alias tuple = args[1 .. $];

    static if (tuple.length)
    {
        alias head = Alias!(tuple[0]);
        alias tail = tuple[1 .. $];
        alias next = GenericEraseAll!(e, tail).result;

        static if (isSame!(e, head))
            alias result = next;
        else
            alias result = AliasSeq!(head, next);
    }
    else
    {
        alias result = AliasSeq!();
    }
}

unittest
{
    static assert(Pack!(EraseAll!(int, short, int, int, 4)).equals!(short, 4));
    static assert(Pack!(EraseAll!(1, real, 3, 1, 4, 1, 5, 9)).equals!(real, 3, 4, 5, 9));
}

template NoDuplicates(TList...)
{
    static if (TList.length == 0)
        alias NoDuplicates = TList;
    else
        alias NoDuplicates = AliasSeq!(TList[0], NoDuplicates!(EraseAll!(TList[0], TList[1 .. $])));
}

unittest
{
    alias Types = AliasSeq!(int, long, long, int, float);

    alias TL = NoDuplicates!(Types);
    static assert(is(TL == AliasSeq!(int, long, float)));
}

unittest
{
    static assert(
        Pack!(
            NoDuplicates!(1, int, 1, NoDuplicates, int, NoDuplicates, real))
        .equals!(1, int, NoDuplicates, real)
    );
}
























// fffffffffffffffffffffffffffffff



























































package:

template Alias(alias a)
{
    static if(__traits(compiles, { alias x = a; }))
        alias Alias = a;
    else static if(__traits(compiles, { enum x = a; }))
        enum Alias a;
    else
        static assert(0, "Cannot alias " ~ a.stringof);
}

template Alias(a...)
{
    alias Alias = a;
}

unittest
{
    enum abc = 1;
    static assert(__traits(compiles, { alias a = Alias!(123); }));
    static assert(__traits(compiles, { alias a = Alias!(abc); }));
    static assert(__traits(compiles, { alias a = Alias!(int); }));
    static assert(__traits(compiles, { alias a = Alias!(1,abc,int); }));
}

private:

private template isSame(ab...)
    if(ab.length == 2)
{
    static if(__traits(compiles, expectType!(ab[0]), expectType!(ab[1])))
    {
        enum isSame = is(ab[0] == ab[1]);
    }
    else static if(!__traits(compiles, expectType!(ab[0])) &&
                   !__traits(compiles, expectType!(ab[1])) &&
                    __traits(compiles, expectBool!(ab[0] == ab[1])))
    {
        static if(!__traits(compiles, &ab[0]) ||
                  !__traits(compiles, &ab[1]))
            enum isSame = (ab[0] == ab[1]);
        else
            enum isSame = __traits(isSame, ab[0], ab[1]);
    }
    else
    {
        enum isSame = __traits(isSame, ab[0], ab[1]);
    }
}
private template expectType(T) {}
private template expectBool(bool b) {}

unittest
{
    static assert( isSame!(int, int));
    static assert(!isSame!(int, short));

    enum a = 1, b = 1, c = 2, s = "a", t = "a";
    static assert( isSame!(1, 1));
    static assert( isSame!(a, 1));
    static assert( isSame!(a, b));
    static assert(!isSame!(b, c));
    static assert( isSame!("a", "a"));
    static assert( isSame!(s, "a"));
    static assert( isSame!(s, t));
    static assert(!isSame!(1, "1"));
    static assert(!isSame!(a, "a"));
    static assert( isSame!(isSame, isSame));
    static assert(!isSame!(isSame, a));

    static assert(!isSame!(byte, a));
    static assert(!isSame!(short, isSame));
    static assert(!isSame!(a, int));
    static assert(!isSame!(long, isSame));

    static immutable X = 1, Y = 1, Z = 2;
    static assert( isSame!(X, X));
    static assert(!isSame!(X, Y));
    static assert(!isSame!(Y, Z));

    int foo();
    int bar();
    real baz(int);
    static assert( isSame!(foo, foo));
    static assert(!isSame!(foo, bar));
    static assert(!isSame!(bar, baz));
    static assert( isSame!(baz, baz));
    static assert(!isSame!(foo, 0));

    int x, y;
    real z;
    static assert( isSame!(x, x));
    static assert(!isSame!(x, y));
    static assert(!isSame!(y, z));
    static assert( isSame!(z, z));
    static assert(!isSame!(x, 0));
}

private template Pack(T...)
{
    alias tuple = T;

    template equals(U...)
    {
        static if (T.length == U.length)
        {
            static if (T.length == 0)
                enum equals = true;
            else
                enum equals = isSame!(T[0], U[0]) && Pack!(T[1 .. $]).equals!(U[1 .. $]);
        }
        else
        {
            enum equals = false;
        }
    }
}

unittest
{
    static assert( Pack!(1, int, "abc").equals!(1, int, "abc"));
    static assert(!Pack!(1, int, "abc").equals!(1, int, "cba"));
}

alias Instantiate(alias Template, Params...) = Template!Params;
