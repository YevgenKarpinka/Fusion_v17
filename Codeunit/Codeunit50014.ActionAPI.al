codeunit 50014 "Action API"
{

    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        msgSalesOrderReleased: Label 'sales order %1 released';

    procedure OnSalesOrderManualRelease(salesOrderNo: Code[20]): Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, salesOrderNo);
        ReleaseSalesDocument.PerformManualRelease(SalesHeader);
        exit(StrSubstNo(msgSalesOrderReleased, SalesHeader."No."));
    end;

}