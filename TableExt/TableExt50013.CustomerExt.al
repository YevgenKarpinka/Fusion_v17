tableextension 50013 "Customer Ext." extends Customer
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Posting Type Shipment Cost"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Type Shipment Cost';
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";

            trigger OnValidate()
            begin
                if "Posting Type Shipment Cost" <> xRec."Posting Type Shipment Cost" then
                    "Sales No. Shipment Cost" := '';
            end;
        }
        field(50001; "Sales No. Shipment Cost"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales No. Shipment Cost';
            TableRelation = IF ("Posting Type Shipment Cost" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                          Blocked = CONST(false))
            ELSE
            IF ("Posting Type Shipment Cost" = CONST(Item)) Item
            ELSE
            IF ("Posting Type Shipment Cost" = CONST(Resource)) Resource
            ELSE
            IF ("Posting Type Shipment Cost" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Posting Type Shipment Cost" = CONST("Charge (Item)")) "Item Charge";

            trigger OnValidate()
            begin

            end;
        }
    }
}