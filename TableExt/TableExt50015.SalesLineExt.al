tableextension 50015 "Sales Line Ext." extends "Sales Line"
{
    // fields
    // {
    //     // Add changes to table fields here
    //     field(50000; "Position Gross Weight"; Decimal)
    //     {
    //         CaptionML = ENU = 'Position Gross Weight', RUS = 'Вес брутто позиции';
    //         Editable = false;
    //         DecimalPlaces = 0 : 5;
    //     }
    // }

    var
        glItem: Record Item;

    procedure GetItemLC(): Decimal
    begin
        if glItem.Get("No.") then
            exit(glItem.LC);
        exit(0);
    end;

    procedure GetItemRS(): Decimal
    begin
        if glItem.Get("No.") then
            exit(glItem.RS);
        exit(0);
    end;

    procedure GetItemMG(): Decimal
    begin
        if glItem.Get("No.") then
            exit(glItem.MG);
        exit(0);
    end;

    procedure GetItemYR(): Decimal
    begin
        if glItem.Get("No.") then
            exit(glItem.YR);
        exit(0);
    end;
}