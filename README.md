# Blue v5

## Next

1. Ideally want separate dicts for effects and body parsing
   1. In/out large overlap except out parsing has noret
   1. For now just put eax/edi in the dictionary to prove the flow is working
   1. Register names are arch specific like parts of backend
1. Start parsing stack effects
   1. Are stack in/out counts enough to validate stack effects?
   1. Each block has counts, each entry has counts
   1. Words like syscall need "trust"/"blessed" since outputs are from side effects
1. Question of how much the frontend/backend should handle flow
   1. Data flow/stack effect validation is all a frontend issue, will create CMD_MOV or similar
1. Keep in mind a backend that serializes the input instead of executing, for use by other backends/tools

