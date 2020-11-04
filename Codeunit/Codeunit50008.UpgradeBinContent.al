codeunit 50008 "Upgrade Bin Content"
{
    Permissions = tabledata "Bin Content" = rm, tabledata "Warehouse Entry" = r;

    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        BinContent: Record "Bin Content";
        BinConMod: Record "Bin Content";
        LotNo: Code[50];
    begin
        BinContent.SetCurrentKey("Lot No.");
        BinContent.SetRange("Lot No.", '');
        if BinContent.FindSet(true, false) then
            repeat
                if BinConMod.Get(BinContent."Location Code", BinContent."Bin Code", BinContent."Item No.",
                        BinContent."Variant Code", BinContent."Unit of Measure Code") then begin
                    LotNo := GetLotNoFromWhseEntry(BinContent."Location Code", BinContent."Bin Code",
                            BinContent."Item No.", BinContent."Variant Code", BinContent."Unit of Measure Code");
                    if LotNo <> '' then begin
                        BinConMod.Validate("Lot No.", LotNo);
                        BinConMod.Modify();
                    end;
                end;
            until BinContent.Next() = 0;
    end;

    local procedure GetLotNoFromWhseEntry(Location: Code[10]; BinCode: Code[20]; Item: Code[20]; VariantCode: Code[10]; UoMCode: Code[10]): Code[50];
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        WhseEntry.SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
        WhseEntry.SetRange("Location Code", Location);
        WhseEntry.SetRange("Bin Code", BinCode);
        WhseEntry.SetRange("Item No.", Item);
        WhseEntry.SetRange("Variant Code", VariantCode);
        WhseEntry.SetRange("Unit of Measure Code", UoMCode);
        if WhseEntry.FindLast() then
            exit(WhseEntry."Lot No.");
        exit('');
    end;
}