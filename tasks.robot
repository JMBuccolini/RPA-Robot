*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves a screenshot of the receipt
...                 Saves the screenshot of the ordered robot.
...                 Create a POF file with both screenshots
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Download Orders File
    Download Orders File

Open Browser on order's page
    Open Browser

Fill the order form
    Fill The Order Form

Transfor to Pdf
    Create PDF

Create a zip file of the orders
    Create ZIP File


*** Keywords ***
Download Orders File
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get Orders
    ${orders_table}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders_table}

Open Browser
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    class:btn-dark

Fill An Order
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Click Button    id:id-body-${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]
    Robot Screenshot    ${row}[Order number]
    Click Button    id:order
    Receipt Screenshot    ${row}[Order number]
    Click Element If Visible    id:order-another
    Click Element If Visible    class:btn-dark

Fill The Order Form
    ${orders}=    Get Orders
    FOR    ${row}    IN    @{orders}
        Wait Until Keyword Succeeds    5x    0.5 sec    Fill An Order    ${row}
    END

Receipt Screenshot
    [Arguments]    ${order_num}
    Wait Until Element Is Visible    id:receipt    timeout=3sec
    ${screenshot}=    Screenshot
    ...    id:receipt
    ...    filename=${OUTPUT_DIR}${/}receipt_screenshots${/}receipt_${order_num}.png
    RETURN    ${screenshot}

Robot Screenshot
    [Arguments]    ${order_num}
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image    timeout=10sec
    ${robot_screenshot}=    Screenshot
    ...    id:robot-preview-image
    ...    filename=${OUTPUT_DIR}${/}robot_screenshot${/}robot_${order_num}.png
    RETURN    ${robot_screenshot}

Create PDF
    ${orders}=    Get Orders
    FOR    ${row}    IN    @{orders}
        ${pdf}=    Create List
        ...    ${OUTPUT_DIR}${/}receipt_screenshots${/}receipt_${row}[Order number].png
        ...    ${OUTPUT_DIR}${/}robot_screenshot${/}robot_${row}[Order number].png
        Add Files To Pdf    ${pdf}    ${OUTPUT_DIR}${/}pdf_orders${/}order_${row}[Order number].pdf
    END

Create ZIP File
    Archive Folder With Zip    ${OUTPUT_DIR}${/}pdf_orders    ${OUTPUT_DIR}${/}pdf_orders.zip
