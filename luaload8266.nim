import serial, os, streams, illwill, sequtils, strutils

proc send_delayed(port: Stream, message: string) =
  for letter in message:
    port.write letter
    sleep(1)
  port.write $char(13) #return character

#opens a serial terminal.
proc terminal_mode(portname: string, baudrate: int32) =
  let port = newSerialStream(portname, baudrate, Parity.None, 8, StopBits.One,
      buffered = false)
  port.setTimeouts(1, 5000)

  stdout.write("\nConnection Established:\n")

  while true:
    var key = getkey()
    case key
    of Key.None:
      discard
    else:
      port.write $char(key)

    try:
      stdout.write port.readChar()
    except TimeoutError:
      discard

  defer: close(port)

#sends file.putcontents() to the esp, char by char so that the mcu isn't
#overwhelmed
proc upload_mode(portname: string, baudrate: int32) =
  var filename: string
  echo "Type the name of the file you want to upload:"
  filename = readline(stdin)
  var f: File
  discard f.open(filename, fmRead)
  let message = "file.putcontents(\'"&filename&"\',[["&f.readAll()&"]])"
  let port = newSerialStream(portname, baudrate, Parity.None, 8, StopBits.One,
      buffered = false)
  port.setTimeouts(1, 5000)
  stdout.write("\nConnection Established. Uploading...\n")
  send_delayed(port, message)
  stdout.write("Upload Complete!\n")

  defer: close(port)

#lists files on the esp. doesn't work reliably.
proc list_mode(portname: string, baudrate: int32) =
  let message = """l = file.list();
for k,v in pairs(l) do 
  print("name:"..k..", size:"..v)
end"""
  let port = newSerialStream(portname, baudrate, Parity.None, 8, StopBits.One,
      buffered = false)
  port.setTimeouts(1, 5000)
  send_delayed(port, message)
  while true: #todo fix
    try:
      stdout.write port.readChar()
    except TimeoutError:
      break

  defer: close(port)


var serialports = toSeq(listSerialPorts())

illwillInit()

var width = terminalWidth()
var height = terminalHeight()

var tb = newTerminalBuffer(width, height)

var portname: string

tb.drawRect(width div 2 - 20, height div 2 - 2, width div 2 + 20, height div 2 + 4)

tb.write(width div 2 - 18, height div 2, fgWhite, "Choose your port")

for i in low(serialports)..high(serialports):
  tb.write(width div 2 - 19 + 5*i, height div 2 + 3, fgGreen, "[" & $i & "]" &
      $serialports[i])

while true:
  var key = getkey()
  case key
  of Key.None:
    discard
  else:
    if isDigit(char(key)):
      let portnum = parseInt($char(key))
      portname = serialports[portnum]
      break
  tb.display()

var baudrate: int32
stdout.write("\n\n\n\n\n\n\n\nBaud Rate?\n")
baudrate = int32(parseint(readline(stdin)))

stdout.write("\nSelect Mode:\n[0]Terminal [1]File Load [2]List Files\n")
while true:
  var op_mode = getkey()
  case op_mode
  of Key.None:
    discard
  of Key.Zero:
    terminal_mode(portname, baudrate)
  of Key.One:
    upload_mode(portname, baudrate)
  of Key.Two:
    list_mode(portname, baudrate)
  else:
    echo "invalid choice, try again."
