A Powershell function used to rerun external executables multiple 
times until they succeed or the retry count is exhausted.

A typical call looks something like this.

```
$podJson = Invoke-CommandWithRetries `
    -ErrorMessage "while getting the Kubernetes pods" `
    -Command kubectl `
    -Arguments @("get", "pod", "mypod", "-o", "json") `
    -RetrySleepSeconds 10 `
    -MaxAttempts 3
```