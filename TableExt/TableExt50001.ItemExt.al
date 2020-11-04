tableextension 50001 "Item Ext." extends Item
{
    fields
    {
        // Add changes to table fields here
        modify("Manufacturer Code")
        {
            trigger OnAfterValidate()
            begin
                if xRec."Manufacturer Code" <> "Manufacturer Code" then "Brand Code" := '';
            end;
        }
        field(50001; "Brand Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Brand;

            trigger OnValidate()
            var
                Brand: Record Brand;
            begin
                if xRec."Brand Code" <> "Brand Code" then begin
                    Brand.Reset();
                    Brand.SetRange(Code, "Brand Code");
                    if Brand.FindFirst() then "Manufacturer Code" := Brand."Manufacturer Code";
                end;
            end;
        }
        field(50002; "Expiration Inventory"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Item Ledger Entry".Quantity where("Item No." = field("No."),
                               "Global Dimension 1 Code" = field("Global Dimension 1 Filter"),
                               "Global Dimension 2 Code" = field("Global Dimension 2 Filter"),
                               "Location Code" = field("Location Filter"),
                               "Drop Shipment" = field("Drop Shipment Filter"),
                               "Variant Code" = field("Variant Filter"),
                               "Lot No." = field("Lot No. Filter"),
                               "Serial No." = field("Serial No. Filter"),
                               "Expiration Date" = field("Expiration Date Filter")));
            CaptionML = ENU = 'Expiration Inventory', RUS = 'Просроченые Запасы';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(50003; "Expiration Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            CaptionML = ENU = 'Expiration Date Filter', RUS = 'Фильтр по дате просрочки';
        }
        field(50004; "Baby Care"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Baby Care', RUS = 'Забота о ребенке';
        }
        field(50005; "Web Item"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Web Item', RUS = 'Web товар';
        }
        field(50006; "Item Form"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Item Form', RUS = 'Форма товара';
        }
        field(50007; "Transfered to eShop"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Transfered to eShop', RUS = 'Отправлено в eShop';
        }
        field(50008; "Warning Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Warning Qty', RUS = 'Количество Предупреждения';
        }
        field(50009; "Web Price"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Web Price', RUS = 'Цена для Web';
            DecimalPlaces = 0 : 2;
        }
    }
}
