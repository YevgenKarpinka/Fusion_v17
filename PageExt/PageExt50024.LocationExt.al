pageextension 50024 "Location Ext." extends "Location Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Pick According to FEFO")
        {
            field("Create Move"; "Create Move")
            {
                ApplicationArea = Warehouse;

                ToolTipML = ENU = 'Specifies that a move line is created, if an appropriate zone and bin from which to pick the item cannot be found.',
                            RUS = 'Указывает, что создается линия перемещения, если не удается найти подходящую зону и корзину, из которой можно выбрать товар.';
            }
        }
    }
}