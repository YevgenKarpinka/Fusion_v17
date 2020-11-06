pageextension 50011 "Posted Purchase Invoice Ext." extends "Posted Purchase Invoice"
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor Invoice No.")
        {
            field("IC Document No."; "IC Document No.")
            {
                ApplicationArea = All;
                Editable = false;
                Importance = Additional;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addafter(Print)
        {
            action("Print Order Customs")
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