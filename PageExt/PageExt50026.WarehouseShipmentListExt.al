pageextension 50026 "Warehouse Shipment List Ext" extends "Warehouse Shipment List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("F&unctions")
        {
            action(DeleteRecords)
            {
                CaptionML = ENU = 'Delete Records',
                            RUS = 'Delete Records';
                ToolTipML = ENU = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.',
                            RUS = 'Просмотр или изменение серийных номеров и номеров партий, присваиваемых товару в документе или в строке журнала.';
                // ApplicationArea = Warehouse;
                Image = ItemTrackingLines;

                trigger OnAction()
                var
                    WhseShipHeader: Record "Warehouse Shipment Header";
                begin
                    CurrPage.SetSelectionFilter(WhseShipHeader);
                    WhseShipHeader.DeleteAll();
                end;
            }
        }
    }

    var
        myInt: Integer;
}