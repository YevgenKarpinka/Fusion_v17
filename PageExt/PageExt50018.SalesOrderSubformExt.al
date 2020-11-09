pageextension 50018 "Sales Order Subform Ext." extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                UpdateForm(true);
            end;
        }
        addafter("Unit Price")
        {
            field(LC; GetItemLC())
            {
                ApplicationArea = All;
            }
            field(RS; GetItemRS())
            {
                ApplicationArea = All;
            }
            field(MG; GetItemMG())
            {
                ApplicationArea = All;
            }
            field(YR; GetItemYR())
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(processing)
        {
            action(TrackingLine)
            {
                CaptionML = ENU = 'Item Tracking Lines Fusion', RUS = 'Строки трассир&овки товаров Fusion';
                ToolTipML = ENU = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.', RUS = 'Просмотр или изменение серийных номеров и номеров партий, присваиваемых товару в документе или в строке журнала.';
                ApplicationArea = ItemTracking;
                Image = ItemTrackingLines;

                trigger OnAction()
                begin
                    OpenItemTrackingLines;
                end;
            }
        }
    }
}