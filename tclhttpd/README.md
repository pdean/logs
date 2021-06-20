

[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )

## installing tclhttpd

    $ mkdir fossil
    $ cd fossil
    $ fossil clone https://core.tcl-lang.org/tclhttpd
    $ cd tclhttpd
    $ ./configure
    $ make
    $ sudo chown -R root.wheel /usr/local
    $ sudo chmod -R 775 /usr/local
    $ make install
    $ mv /usr/local/lib/tclhttpd3.4.3/ /usr/local/lib/tclhttpd3.5.2

test it

    $ tclsh /usr/local/bin/httpd.tcl -debug 1

in another console

    $ firefox localhost:8015
 
