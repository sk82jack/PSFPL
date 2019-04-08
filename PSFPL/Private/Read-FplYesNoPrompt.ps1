function Read-FplYesNoPrompt {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [string]
        $YesMessage,

        [Parameter()]
        [string]
        $NoMessage
    )
    $Options = [System.Management.Automation.Host.ChoiceDescription[]](
        [System.Management.Automation.Host.ChoiceDescription]::new('&Yes', $YesMessage),
        [System.Management.Automation.Host.ChoiceDescription]::new('&No', $NoMessage)
    )
    $Host.UI.PromptForChoice($Title, $Message, $Options, 1)
}
