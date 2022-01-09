*** Settings ***
Suite Setup                   Setup
Suite Teardown                Teardown
Test Setup                    Reset Emulation
Test Teardown                 Test Teardown
Resource                      ${RENODEKEYWORDS}

*** Variables ***
${CPU}                        sysbus.cpu
${UART}                       sysbus.uart0
${URI}                        @https://dl.antmicro.com/projects/renode
${SCRIPT}                     ${CURDIR}/sifive_fe310.resc

*** Test Cases ***
Hello World
    [Documentation]           Runs Hello world example from freedom-e-sdk
    [Tags]                    uart  freedom-e
    Execute Command           $bin=@${CURDIR}/freedom-e-sdk/software/hello/debug/hello.elf
    Execute Script            ${SCRIPT}

    Create Terminal Tester    ${UART}  endLineOption=TreatCarriageReturnAsEndLine
    Start Emulation

    Wait For Prompt On Uart   Hello, World! 

Should Run Shell
    [Documentation]           Runs Zephyr's 'shell' sample on SiFive Freedom E310 platform.
    [Tags]                    zephyr  uart  interrupts
    Execute Command           $bin = ${URI}/zephyr-fe310-shell.elf-s_323068-cf87169150ecdb30ad5a14c87ae209c53dd3eca2
    Execute Script            ${SCRIPT}
    # Work around for Zephy on Sifive
    Execute Command           cpu PC `sysbus GetSymbolAddress "vinit"`
    
    Create Terminal Tester    ${UART}  endLineOption=TreatCarriageReturnAsEndLine
    Start Emulation

    Wait For Prompt On Uart   shell>
    # this sleep here is to prevent against writing to soon on uart - it can happen under high stress of the host CPU - when an uart driver is not initalized which leads to irq-loop
    Sleep                     3
    Write Line To Uart        select sample_module
    Wait For Prompt On Uart   sample_module>
    Write Line To Uart        ping
    Wait For Line On Uart     pong

Get kernel version
    [Documentation]           Runs Zephyr's 'shell' sample on SiFive Freedom E310 platform.
    [Tags]                    zephyr  uart  interrupts
    Execute Command           $bin = ${URI}/zephyr-fe310-shell.elf-s_323068-cf87169150ecdb30ad5a14c87ae209c53dd3eca2
    Execute Script            ${SCRIPT}
    # Work around for Zephy on Sifive
    Execute Command           cpu PC `sysbus GetSymbolAddress "vinit"`
    Create Terminal Tester    ${UART}  endLineOption=TreatCarriageReturnAsEndLine
    Start Emulation

    Wait For Prompt On Uart   shell>
    # this sleep here is to prevent against writing to soon on uart - it can happen under high stress of the host CPU - when an uart driver is not initalized which leads to irq-loop
    Sleep                     3
    Write Line To Uart        select kernel
    Wait For Prompt On Uart   kernel>
    Write Line To Uart        version
    Wait For Line On Uart     Zephyr version 1.10.0


