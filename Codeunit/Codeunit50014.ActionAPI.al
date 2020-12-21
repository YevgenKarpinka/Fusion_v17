codeunit 50014 "Action API"
{

    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        msgSalesOrderReleased: Label 'sales order %1 released';

    procedure OnSalesOrderManualRelease(salesOrderId: Text[50]): Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, salesOrderId);
        ReleaseSalesDocument.PerformManualRelease(SalesHeader);
        exit(StrSubstNo(msgSalesOrderReleased, SalesHeader."No."));
    end;

}