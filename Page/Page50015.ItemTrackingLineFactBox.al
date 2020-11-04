page 50015 "Item Tracking Line FactBox"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Reservation Entry";
    CaptionML = ENU = 'Item Tracking Line', RUS = 'Трассировки товара строки';
    AccessByPermission = tabledata "Reservation Entry" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater("Item Tracking List")
            {
                field("Lot No."; ReservEntryLotNo."Lot No.")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date"; itemTrackingMgt.GetItemTrackingExpirationDateByLotNo(ReservEntryLotNo."Lot No.", Rec."Item No."))
                {
                    ApplicationArea = All;
                }
                field(Quantity; ReservEntryLotNo.Quantity)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        ReservEntryLotNo: Record "Reservation Entry";
        itemTrackingMgt: Codeunit "Item Tracking Mgt.";

    trigger OnAfterGetRecord()
    begin
        if ReservEntryLotNo.Get(Rec."Entry No.", true) then;
    end;
}