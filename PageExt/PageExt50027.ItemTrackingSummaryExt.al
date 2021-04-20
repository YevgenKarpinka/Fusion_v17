pageextension 50027 "Item Tracking Summary Ext" extends "Item Tracking Summary"
{
    layout
    {
        // Add changes to page layout here
        addafter("Lot No.")
        {
            field(DescriptionLotNo; GetDescriptionLotNo("Lot No."))
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Description Lot',
                            RUS = 'Описание лота';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    local procedure GetDescriptionLotNo(LotNo: Code[50]): Text[100]
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetCurrentKey("Lot No.");
        ReservationEntry.SetRange("Lot No.", LotNo);
        if ReservationEntry.FindFirst() then
            exit(ReservationEntry.Description);

        exit('');
    end;
}