# NOTE: readme.txt contains important information you need to take into account
# before running this suite.

*** Settings ***
Resource                        ../resources/common.robot
Library                         Collections
Library                         QForce
Library                         RequestsLibrary
Suite Setup                     Setup Browser
Suite Teardown                  End suite                  


*** Test Cases ***

    ## Completed

Close All Console Tabs Test Case
    [Documentation]             Closes all the console tabs of console application
    Login
    LaunchApp                   Sales Console
    Close All Console Tabs


Select List View Test Case
    [Documentation]             Select the given list view for any object
    Login
    LaunchApp                   Sales
    ClickText                   Accounts
    Select List View            New This Week


    ## In Progress

Delete Salesforce Record Test Case
    Login
    Client Authenticate         ${domain}                   ${Id}                       ${secretkey}
    ${token}=                   GetAccessToken
    Log To Console              ${token}

    ${ACCESS_TOKEN}=            Set Variable                ${token}
    ${RECORD_I}=                Set Variable                00UgL000001p6HJUAY

    Delete Salesforce Record    ${ACCESS_TOKEN}             ${domain}                 ${RECORD_I}



*** Keywords ***

Select List View    
    [Arguments]                 ${ListViewName}
    ${Dialog}=                  Set Variable                //section[@role='dialog']//lightning-base-combobox-item
    ${Element}=                 Set Variable                //span[normalize-space()='${ListViewName}']
    ${ListViewDropdown}=        Set Variable                //button[contains(@title,'Select a List View')]

    VerifyElement               ${ListViewDropdown}         10
    ClickElement                ${ListViewDropdown}
    VerifyElement               ${Dialog}                   5
    ClickElement                ${Element}


Close All Console Tabs
    ${tabElement}=              Set Variable                //div[contains(@class,'secondary')]//button[contains(@title,'Close')]
    Sleep                       2s
    ${count}=                   GetElementCount             ${tabElement}
    FOR                         ${i}                        IN RANGE                    ${count}
        ClickElement            ${tabElement}
        Sleep                   5ms
    END


Delete Salesforce Record

    [Arguments]                 ${ACCESS_TOKEN}             ${INSTANCE}                 ${RECORD_I}
    ${header}=                  Create Dictionary           Authorization=Bearer ${ACCESS_TOKEN}                    Content-Type=application/json
    ${API_VERSION}=             Set Variable                v60.0
    Create Session              sf                          ${INSTANCE}                 headers=${header}           verify=${False}
    # Get all sobjects to find the object type
    ${sobjects_response}=       GET On Session              sf                          /services/data/${API_VERSION}/sobjects/
    Should Be Equal As Numbers                              ${sobjects_response.status_code}                        200

    ${sobjects}=                Get From Dictionary         ${sobjects_response.json()}                             sobjects
    ${record_prefix}=           Get Substring               ${RECORD_I}                 0                           3

    # Find matching object
    ${object_name}=             Find Object By Prefix       ${sobjects}                 ${record_prefix}

    Log To Console              Detected object type: ${object_name}

    ${delete_endpoint}=         Set Variable                /services/data/${API_VERSION}/sobjects/${object_name}/${RECORD_I}
    ${delete_response}=         DELETE On Session           sf                          ${delete_endpoint}          expected_status=204




Find Object By Prefix
    [Documentation]             Find object name from record ID prefix
    [Arguments]                 ${sobjects}                 ${prefix}

    FOR                         ${sobject}                  IN                          @{sobjects}
        ${key_prefix}=          Get From Dictionary         ${sobject}                  keyPrefix                   default=${EMPTY}
        ${is_match}=            Run Keyword And Return Status                           Should Be Equal             ${key_prefix}          ${prefix}
        IF                      ${is_match}
            ${object_name}=     Get From Dictionary         ${sobject}                  name
            RETURN              ${object_name}
        END
    END

    Fail                        Could not find object type for prefix: ${prefix}
