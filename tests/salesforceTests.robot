# NOTE: readme.txt contains important information you need to take into account
# before running this suite.

*** Settings ***
Resource                    ../resources/common.robot
Suite Setup                 Setup Browser
Suite Teardown              End suite


*** Test Cases ***
Close All Console Tabs Test Case
    [Documentation]         Closes all the console tabs of console application
    Login
    LaunchApp               Sales Console
    Close All Console Tabs


Select List View Test Case
    [Documentation]         Select the given list view for any object
    Login
    LaunchApp               Sales
    ClickText               Accounts
    Select List View        New This Week



*** Keywords ***

Select List View    
    [Arguments]             ${ListViewName}
    ${Dialog}=              Set Variable                //section[@role='dialog']//lightning-base-combobox-item
    ${Element}=             Set Variable                //span[normalize-space()='${ListViewName}']
    ${ListViewDropdown}=    Set Variable                //button[contains(@title,'Select a List View')]

    VerifyElement           ${ListViewDropdown}         10
    ClickElement            ${ListViewDropdown}
    VerifyElement           ${Dialog}                   5
    ClickElement            ${Element}


Close All Console Tabs
    ${tabElement}=          Set Variable                //div[contains(@class,'secondary')]//button[contains(@title,'Close')]
    Sleep                   2s
    ${count}=               GetElementCount             ${tabElement}
    FOR                     ${i}                        IN RANGE                    ${count}
        ClickElement        ${tabElement}
        Sleep               5ms
    END
