pageextension 50010 "Posted Purchase Invoices Ext." extends "Posted Purchase Invoices"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("&Print")
        {
            action("Print Invoice Customs")
            {
                ApplicationArea = All;
                Image = PurchaseInvoice;
                CaptionML = ENU = 'Purchase Invoice Customs', RUS = 'Таможенный счет покупки';

                trigger OnAction()
                var
                    _PurchInvHeader: Record "Purch. Inv. Header";
                begin
                    _PurchInvHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(_PurchInvHeader);
                    Report.Run(Report::"Purchase Invoice Customs", true, true, _PurchInvHeader);
                end;
            }
        }
    }
}