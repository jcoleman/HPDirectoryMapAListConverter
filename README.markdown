Why?
----

Hampton Park Baptist Church wanted a way to display their member's directory on Google Map. MapAList.com provided this ability, but the directory spreadsheet wasn't in a format that could be used.

What?
-----

This utility expects CSV files in the following format:

    <blank>,HOUSEHOLD NAME   Phone Number
    First/Couple's Name,<blank>
    Optional Kid's Name 1,<blank>
    Optional Kid's Name 2,<blank>
    ...continued kid's names,<blank>
    <blank>,Address 1
    <blank>,Address 2
    <blank>,<blank>
    ...

And outputs CSV files in the following format:

    Household,More Information,Address
    <HOUSEHOLD NAME>,<First/Couple's Name> (<Kid's Names>),<Address>
    ...

License
-------

This project is licensed under the MIT license. All copyright rights are retained by myself.

Copyright (c) 2013 James Coleman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.