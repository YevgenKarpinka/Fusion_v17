pageextension 50007 "Purchase Order List Ext." extends "Purchase Order List"
{
    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action("Print Order Customs")
            {
                ApplicationArea = All;
                Image = PurchaseInvoice;
                CaptionML = ENU = 'Purchase Order Customs', RUS = 'Таможенный заказ покупки';

                trigger OnAction()
                var
                    _PurchaseHeader: Record "Purchase Header";
                begin
                    _PurchaseHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_PurchaseHeader);
                    Report.Run(Report::"Purchase Order Customs", true, true, _PurchaseHeader);
                end;
            }
        }
    }
}