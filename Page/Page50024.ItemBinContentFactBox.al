page 50024 "Item Bin Content FactBox"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Item Ledger Entry";
    CaptionML = ENU = 'Item Tracking Entries', RUS = 'Операции трассировки товара';
    AccessByPermission = tabledata "Bin Content" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Item Bin Content")
            {
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Bin Code"; BinContent."Bin Code")
                {
                    ApplicationArea = All;
                }
                field("Bin Type Code"; BinContent."Bin Type Code")
                {
                    ApplicationArea = All;
                }
                field("Available Quantity"; BinContent.CalcQtyAvailToTakeUOM())
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Pick Qty."; BinContent."Pick Qty.")
                {
                    ApplicationArea = All;
                }
                field("Put-away Qty."; BinContent."Put-away Qty.")
                {
                    ApplicationArea = All;
                }
                field("Neg. Adjmt. Qty."; BinContent."Neg. Adjmt. Qty.")
                {
                    ApplicationArea = All;
                }
                field("Pos. Adjmt. Qty."; BinContent."Pos. Adjmt. Qty.")
                {
                    ApplicationArea = All;
                }
                // field("Document Date"; Rec."Document Date")
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BinContent.SetRange("Location Code", Rec."Location Code");
        BinContent.SetRange("Item No.", Rec."Item No.");
        BinContent.SetRange("Variant Code", Rec."Variant Code");
        BinContent.SetRange("Unit of Measure Code", Rec."Unit of Measure Code");
        BinContent.SetFilter("Lot No. Filter", Rec."Lot No.");
        if BinContent.FindSet(false, false) then
            repeat
                if BinContent.CalcQtyAvailToTakeUOM() > 0 then exit;
            until BinContent.Next() = 0;
    end;

    var
        BinContent: Record "Bin Content";
}