pageextension 50008 "Purchase Order Ext." extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
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
        addafter("Whse. Receipt Lines")
        {
            action(PutAwayLines)
            {
                ApplicationArea = Warehouse;
                Image = PickLines;
                CaptionML = ENU = 'Put-away Lines', RUS = 'Строки приемки';
                ToolTipML = ENU = 'View the related Put-aways.', RUS = 'Просмотр связанных приемок.';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Warehouse Activity Lines";
                RunPageView = SORTING("Whse. Document No.", "Whse. Document Type", "Activity Type") WHERE("Activity Type" = CONST("Put-away"));
                RunPageLink = "Source Document" = CONST("Purchase Order"), "Source No." = FIELD("No.");
            }
        }
        addafter("&Print")
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