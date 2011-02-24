/*
mSASL Version 1.0 Beta [sans DLL] designed by Kyle Travaglini
* To use this script you must have the proper DLL
* All I ask is you leave the credit line within the main dialog
* PLEASE read the SASLreadme.txt file before asking questions!


[sans DLL changes]
- $dll call removed and replaced with scripted version [$SASL(username,password).plain]
- $decode call removed and replaced with plain text [mIRC disables $decode by default]
* a few other edits to fix bugs and add a bit more function

* only plain is supported for AuthType [blank defaults to plain]
* auth timeout support added [blank defaults to 30 seconds]
*/

alias f2 { dialog -m SASL.main SASL.main }
menu menubar,status {
  -
  $mSASL.version: f2
  -
}
alias mSASL.ver { return 1.0 }
alias mSASL.version { return mSASL $+(v,$mSASL.ver) Beta [sans DLL] }

alias shname { return SASL }
alias shfile { return $+(&quot;,$scriptdir,SASL.hsh,&quot;) }
alias SASL {
  if ($isid) {
    if ($prop == nlist) { return $hget($shname,NLIST) }
    if ($prop == timeout) { return $hget($shname,$+($1,:TIMEOUT)) }
    if ($prop == user) { return $hget($shname,$+($1,:USER)) }
    if ($prop == passwd) { return $hget($shname,$+($1,:PASSWD)) }
    if ($prop == domain) { return $hget($shname,$+($1,:DOMAIN)) }
    if ($prop == realname) { return $hget($shname,$+($1,:REALNAME)) }
    if ($prop == status) { return $hget($shname,$+($1,:STATUS)) }
    if ($prop == authtype) { return $hget($shname,$+($1,:AUTHTYPE)) }
    if ($prop == plain) {
      bset -t &amp;auth 1 $1
      bset -t &amp;auth $calc( $bvar(&amp;auth,0) + 2 ) $1
      bset -t &amp;auth $calc( $bvar(&amp;auth,0) + 2 ) $2
      var %len = $encode(&amp;auth,mb)
      return $bvar(&amp;auth,1,%len).text
    }
  }
}
alias sd { hadd -m $shname $+($1,:,$2) $3- }

alias -l mSASL {
  var %cid = $1, %network = $2
  if (%network isin $SASL(%network).nlist) {
    if ($prop == timer) { return $+(.timer,mSASL.TimeOut.,%cid,.,%network) }
    elseif ($prop == timeout) {
      if ($SASL(%network).status == Authenticating) { scid %cid .quote CAP END }
    }
  }
}

on *:START:{
  if (!$hget($shname)) { hmake $shname 50 }
  if ($exists($shfile)) { hload -b $shname $shfile }
}
on *:EXIT:{
  if (($hget($shname)) &amp;&amp; ($hget($shname,0).item &gt; 0)) { hsave -b $shname $shfile }
}

on ^*:LOGON:*:{
  if ($network isin $SASL($network).nlist) {
    .quote CAP LS
    .quote NICK $nick
    .quote USER $SASL($network).user $SASL($network).domain 1 : $+ $SASL($network).realname
    sd $network STATUS Connecting
    haltdef
  }
}
on *:CONNECT:{
  if ($network isin $SASL($network).nlist) { sd $network STATUS Connected }
}
on *:DISCONNECT:{
  if ($network isin $SASL($network).nlist) { sd $network STATUS Disconnected }
}

raw CAP:*LS*:{
  if ($network isin $SASL($network).nlist) {
    .quote CAP REQ :multi-prefix sasl
    var %t = $mSASL($cid,$network).timer
    %t 1 $SASL($network).timeout noop $mSASL($cid,$network).timeout
  }
}
raw CAP:*ACK*:{
  if ($network isin $SASL($network).nlist) {
    .quote AUTHENTICATE $SASL($network).authtype
    sd $network STATUS Authenticating
  }
}
raw AUTHENTICATE:+:{
  if ($network isin $SASL($network).nlist) {
    if ($lower($SASL($network).authtype) == plain) {
      .quote AUTHENTICATE $SASL($SASL($network).user, $SASL($network).passwd).plain
    }
    else { .quote CAP END }
    haltdef
  }
}
raw *:*:{
  if ($network isin $SASL($network).nlist) {
    if ($numeric isnum 903) {
      .quote CAP END
      sd $network STATUS Authenticated
      var %t = $mSASL($cid,$network).timer
      %t off
    }
    elseif ($numeric isnum 904-907) { .quote CAP END }
  }
}

dialog SASL.main {
  title &quot;SASL Manager&quot;
  size -1 -1 150 145
  option dbu
  box &quot;Server List&quot; 1, 5 3 140 113
  text &quot;Created by Kyle Travaglini&quot; 3, 40 135 65 12
  list 4, 10 13 80 104, vsbar, edit
  button &quot;Add&quot; 5, 96 13 43 12
  button &quot;Edit&quot; 6, 96 30 43 12
  button &quot;Delete&quot; 7, 96 47 43 12
  button &quot;Save&quot; 10, 96 64 43 12
  button &quot;Load&quot; 11, 96 81 43 12
  button &quot;OK&quot; 8, 27 120 43 12, ok
  button &quot;Update SASL&quot; 9, 77 120 43 12
}

dialog SASL.edit {
  title &quot;Network Configuration&quot;
  size -1 -1 150 120
  option dbu
  box &quot;Network Settings&quot; 1, 5 3 140 97
  text &quot;Network:&quot; 2, 10 13 36 10, right
  edit &quot;&quot; 3, 48 12 92 10
  text &quot;Username:&quot; 4, 10 25 36 10, right
  edit &quot;&quot; 5, 48 24 92 10
  text &quot;NS Password:&quot; 6, 10 37 36 10, right
  edit &quot;&quot; 7, 48 36 92 10
  text &quot;Domain:&quot; 8, 10 49 36 10, right
  edit &quot;&quot; 9, 48 48 92 10
  text &quot;Real Name:&quot; 10, 10 61 36 10, right
  edit &quot;&quot; 11, 48 60 92 10
  text &quot;Timeout:&quot; 12, 10 73 36 10, right
  edit &quot;&quot; 13, 48 72 92 10
  text &quot;AuthType:&quot; 14, 10 85 36 10, right
  edit &quot;&quot; 15, 48 84 92 10
  button &quot;OK&quot; 16, 27 105 43 12, ok
  button &quot;Cancel&quot; 17, 77 105 43 12, cancel
}

dialog SASL.deletewarn {
  title &quot;SASL&quot;
  size -1 -1 120 40
  option dbu
  text &quot;You must specify a network to delete.&quot; 1, 13 5 100 10
  button &quot;OK&quot; 2, 40 20 43 12, ok
}

dialog SASL.editwarn {
  title &quot;SASL&quot;
  size -1 -1 120 40
  option dbu
  text &quot;You must specify a network to edit.&quot; 1, 13 5 100 10
  button &quot;OK&quot; 2, 40 20 43 12, ok
}

on *:DIALOG:SASL.*:*:*:{
  if ($dname == SASL.main) {
    if ($devent == init) {
      did -r $dname 3
      did -a $dname 3 Created by Kyle Travaglini
      var %net_iter = 1
      while (%net_iter &lt;= $numtok($SASL().nlist,44)) {
        did -a $dname 4 $gettok($SASL().nlist,%net_iter,44)
        inc %net_iter 1      
      }
      ;// disable 'Update SASL' button
      did -b $dname 9
    }
    if ($devent == sclick) {
      if ($did == 5) { dialog -m SASL.edit SASL.edit }
      elseif ($did == 6) {
        if ($did($dname,4).seltext) {
          hadd -m $shname EDIT True
          dialog -m SASL.edit SASL.edit
        }
        else { dialog -m SASL.deletewarn SASL.deletewarn }
      }
      elseif ($did == 7) {
        if ($did($dname,4).sel) {
          if ($?!=&quot;Are you certain you wish to delete $did($dname,4).seltext $+ ?&quot;) {
            hdel -w $shname $+($did($dname,4).seltext,:*)
            hadd -m $shname NLIST $remtok($SASL().nlist,$did($dname,4).seltext,1,44)
            did -d $dname 4 $did($dname,4).sel
          }
        }
        else { dialog -m SASL.deletewarn SASL.deletewarn }
      }
      elseif ($did == 9) { usasl } 
      elseif ($did == 10) { hsave -b $shname $shfile }
      elseif ($did == 11) {
        hload -b $shname $shfile
        did -r $dname 4
        var %net_iter = 1
        while (%net_iter &lt;= $numtok($SASL().nlist,44)) {
          did -a $dname 4 $gettok($SASL().nlist,%net_iter,44)
          inc %net_iter 1      
        }
      }
    }
  }
  elseif ($dname == SASL.edit) {
    if ($devent == init) {
      if ($hget($shname,EDIT) == True) {
        var %network = $did(SASL.main,4).seltext
        did -a $dname 3 %network
        did -a $dname 5 $SASL(%network).user
        did -a $dname 7 $SASL(%network).passwd
        did -a $dname 9 $SASL(%network).domain
        did -a $dname 11 $SASL(%network).realname
        did -a $dname 13 $SASL(%network).timeout
        did -a $dname 15 $SASL(%network).authtype
      }
    }
    if ($devent == sclick) {
      if ($did == 16) {
        var %network = $did($dname,3)
        if ($hget($shname,EDIT) == True) { hadd -m $shname NLIST $remtok($SASL().nlist,%network,1,44) }
        else {
          if ($findtok($SASL().nlist,%network,1,44)) {
            if ($?!=&quot; $+ %network already exists; overwrite?&quot;) {
              hadd -m $shname NLIST $remtok($SASL().nlist,%network,1,44)
            }
            else { halt }
          }
        }
        hdel $shname EDIT
        hadd -m $shname NLIST $+($SASL().nlist,$chr(44),%network)
        sd %network USER $did($dname,5)
        sd %network PASSWD $did($dname,7)
        sd %network DOMAIN $iif($did($dname,9),$v1,0)
        sd %network REALNAME $iif($did($dname,11),$v1,$iif($fullname,$v1,*))
        sd %network TIMEOUT $iif($did($dname,13),$v1,30)
        sd %network AUTHTYPE $iif($did($dname,15),$upper($v1),PLAIN)
        var %net_iter = 1
        did -r SASL.main 4
        while (%net_iter &lt;= $numtok($SASL().nlist,44)) {
          did -a SASL.main 4 $gettok($SASL().nlist,%net_iter,44)
          inc %net_iter 1      
        }
      }
    }
  }
}
;;
