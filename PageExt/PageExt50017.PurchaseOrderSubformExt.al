pageextension 50017 "Purchase Order Subform Ext." extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        // addlast(processing)
        // {
        //     action(TrackingLine)
        //     {
        //         CaptionML = ENU = 'Item Tracking Lines Fusion', RUS = 'Строки трассир&овки товаров Fusion';
        //         ToolTipML = ENU = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.', RUS = 'Просмотр или изменение серийных номеров и номеров партий, присваиваемых товару в документе или в строке журнала.';
        //         ApplicationArea = ItemTracking;
        //         Image = ItemTrackingLines;

        //         trigger OnAction()
        //         begin
        //             OpenItemTrackingLines;
        //         end;
        //     }
        // }
        addafter(OrderTracking)
        {
            action("Split Line")
            {
                ApplicationArea = All;
                Image = Splitlines;
                CaptionML = ENU = 'Split Line', RUS = 'Разделить строку';

                trigger OnAction()
                begin
                    PurchaseDocMgt.SplitPurchaseLine(Rec);
                end;
            }
        }
    }
    var
        PurchaseDocMgt: Codeunit "Purchase Document Mgt.";
}