table 50006 "Integration Log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            CaptionML = ENU = 'Entry No.', RUS = 'Операция Но.';
        }
        field(2; "Operation Date"; DateTime)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Operation Date', RUS = 'Дата операции';
        }
        field(3; "Source Operation"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Source Operation', RUS = 'Источник операции';
        }
        field(4; Success; Boolean)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Success', RUS = 'Успех';
        }
        field(5; Request; Blob)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Request', RUS = 'Запрос';
        }
        field(6; Response; Blob)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Response', RUS = 'Ответ';
        }
        field(7; "Rest Method"; Code[10])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Success', RUS = 'Успех';
        }
        field(8; URL; Text[250])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'URL', RUS = 'Запрос';
        }
        field(9; Autorization; Text[250])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Autorization', RUS = 'Авторизация';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK; "Source Operation", Success)
        { }
    }

    procedure SetRequest(NewRequest: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Request);
        Request.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewRequest);
        Modify;
    end;

    procedure GetRequest(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Request);
        Request.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;

    procedure SetResponse(NewResponse: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Response);
        Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewResponse);
        Modify;
    end;

    procedure GetResponse(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Response);
        Response.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;
}