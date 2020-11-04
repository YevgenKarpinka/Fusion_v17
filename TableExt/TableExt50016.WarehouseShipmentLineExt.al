tableextension 50016 "Warehouse Shipment Line Ext." extends "Warehouse Shipment Line"
{
    fields
    {
        // Add changes to table fields here
    }


    var
        HideValidationDialog: Boolean;
        Text011: Label 'Nothing to handle.';

    procedure CreatePickDocAvailable(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        WhseShptHeader2.TestField(Status, WhseShptHeader2.Status::Released);
        WhseShptLine.SetFilter(Quantity, '>0');
        WhseShptLine.SetRange("Completely Picked", false);
        if WhseShptLine.Find('-') then
            CreatePickDocFromWhseShptAlailable(WhseShptLine, WhseShptHeader2, HideValidationDialog)
        else
            if not HideValidationDialog then
                Message(Text011);
    end;

    local procedure CreatePickDocFromWhseShptAlailable(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean)
    var
        WhseShipmentCreatePick: Report "Whse.-Shpt Create Pick Avail";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if not IsHandled then begin
            WhseShipmentCreatePick.SetWhseShipmentLine(WhseShptLine, WhseShptHeader);
            WhseShipmentCreatePick.SetHideValidationDialog(HideValidationDialog);
            WhseShipmentCreatePick.UseRequestPage(not HideValidationDialog);
            WhseShipmentCreatePick.RunModal;
            WhseShipmentCreatePick.GetResultMessage;
            Clear(WhseShipmentCreatePick);
        end;
    end;
}