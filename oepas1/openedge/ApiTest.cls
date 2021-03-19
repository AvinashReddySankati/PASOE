@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : ApiTest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : STARK
    Created     : Fri Mar 19 17:56:07 IST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ApiTest: 
    

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/

    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    METHOD PUBLIC VOID getInfo(OUTPUT TestMsg AS CHARACTER):
        
        TestMsg = "Hey!!! You are Sucessfull.".

    END METHOD.

END CLASS.