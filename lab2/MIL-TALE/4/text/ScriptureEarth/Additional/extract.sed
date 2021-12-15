1,/[<]div id="content"/d
/Visite a /d
/toolbar-bottom/,$d
/div class="video/,/[<]\/div[>]/d
s/id="T[^"]*"//g
s@[<]span id="bookmark[^"]*"[>][<]/span[>]@@g
s@[<]a id="v[^"]*"[>][<]/a[>]@@g
s@[<]span class="txs"[>]&nbsp;[<]/span[>]@ @g
s@[<]div class="footer".*$@@
s@[<]div class="c-drop"[>][1-9][0-9]*[<]/div[>]@ @g
s@  *class="txs"@@g
s@[<]div class="p"[>][<]div[>]@ @g
s@[<]/*div[>]@ @g
s@[<]div [^>]*[>]@ @g
s@[<]span class="v"[>]\([1-9][-0-9]*\)[<]/span[>]@\n<strong>\1</strong> @g
s@[<]/*sup[>]@@g
s@[<]/*span[^>]*[>]@@g
s@[<]/body[>]@@i
s@[<]/html[>]@@i
/^ *[(].*href=/d
s@&nbsp;@ @gm
s@   *@ @gm
s@^  *$@@gm
/^$/d

