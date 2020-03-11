function RetryBlock
{
  Param(
        [Parameter(Mandatory = $true)]
          [Scriptblock]
          $codeBlock,
          [Parameter(Mandatory = $false)]
          [int]
          $retryCount = 10,
          [Parameter(Mandatory = $false)]
          [int]
          $retryInterval = 15
        )

  $succeed = $false
  while ($retryCount -gt 0) {
    try {
      $lastErrorConfig = $ErrorActionPreference
      $ErrorActionPreference = "Stop"

      Write-Progress "Executing command: $codeBlock"
      $ret = &$codeBlock -ErrorAction Stop
      Write-Progress $ret
      Write-Progress "Executing command succeeded"

      $succeed = $true
      $ErrorActionPreference = $lastErrorConfig
      return $ret
    }
    catch {
      $lastError = $_
      Write-Warning  "Command failed:"
      Write-Warning  $lastError
      Start-Sleep $retryInterval
      $retryCount--
      if ($retryCount -gt 0) {
        Write-Warning  "Retrying command"
      }
    }
  }
  if (!$succeed) {
    Write-Error "Command failed, too many retries:"
    Write-Error $lastError
    throw $lastError
  }
  #end retry block
}


Export-ModuleMember -Function RetryBlock