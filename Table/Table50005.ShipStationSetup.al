table 50005 "ShipStation Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
            CaptionML = ENU = 'Primary Key', RUS = 'Первичный ключ';
        }
        field(2; "ShipStation Integration Enable"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Integration Enable', RUS = 'Интегрировать с ShipStation';
        }
        field(3; "Order Status Update"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Order Status Update', RUS = 'Обновлять статус заказа';
        }
        field(4; "Show Error"; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Show Error', RUS = 'Показывать ошибку';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        isEditable: Boolean;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}