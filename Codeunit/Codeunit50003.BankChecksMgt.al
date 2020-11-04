codeunit 50003 "Bank Checks Mgt."
{
    Permissions = tabledata "General Ledger Setup" = r, tabledata "Bank Check Journal Line" = rimd,
    tabledata "Gen. Journal Line" = rimd, tabledata "Gen. Journal Template" = r,
    tabledata "Gen. Journal Batch" = r, tabledata "G/L Entry" = r;

    trigger OnRun()
    begin

    end;

    procedure SetBankCheckStatus(_BankCheck: Record "Bank Check Journal Line"; _newStatus: Integer)
    begin
        if _newStatus = 0 then begin
            if _BankCheck.Status = _BankCheck.Status::Rejected then begin
                _BankCheck.Status := _newStatus;
            end;
        end else begin
            _BankCheck.Status := _newStatus;
        end;
        _BankCheck.Modify(true);
        if _BankCheck.Status = _BankCheck.Status::Confirmed then begin
            // Create Payment Journal Line
            CreatePaymentFromBankCheck(_BankCheck);
        end;
    end;

    local procedure GetGLSetup()
    begin
        GLSetup.Get();
    end;

    procedure CreatePaymentFromBankCheck(_BankCheck: Record "Bank Check Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        procesGenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
    begin
        GetGLSetup();
        GLSetup.TestField("Journal Template Name");
        GLSetup.TestField("Journal Batch Name");
        GenJnlTemplate.GET(GLSetup."Journal Template Name");
        GenJnlBatch.GET(GLSetup."Journal Template Name", GLSetup."Journal Batch Name");
        GenJnlBatch.TestField("No. Series");
        GenJnlTemplate.TestField("Source Code");
        // GenJnlBatch.TestField("Reason Code");

        procesGenJnlLine.SetRange("Journal Template Name", GLSetup."Journal Template Name");
        procesGenJnlLine.SetRange("Journal Batch Name", GLSetup."Journal Batch Name");
        procesGenJnlLine.SetRange("External Document No.", _BankCheck."Bank Check No.");
        procesGenJnlLine.SetRange("Document Date", _BankCheck."Bank Check Date");
        if not procesGenJnlLine.IsEmpty then
            exit; // instead; go to the document

        if PostedBankCheckExist(_BankCheck."Bank Check No.") then begin
            Message(msgBankCheckNoExist, _BankCheck."Bank Check No.");
            exit;
        end;

        procesGenJnlLine.SetRange("External Document No.");
        procesGenJnlLine.SetRange("Document Date");
        if procesGenJnlLine.FindLast() then
            LineNo := procesGenJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := GLSetup."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GLSetup."Journal Batch Name";
        GenJnlLine."Line No." := LineNo;

        GenJnlLine."Posting Date" := _BankCheck."Bank Check Date";
        GenJnlLine."Document Date" := _BankCheck."Bank Check Date";

        CLEAR(NoSeriesMgt);
        GenJnlLine."Document No." := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", GenJnlLine."Posting Date", true);

        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

        GenJnlLine.Validate("Account No.", _BankCheck."Customer No.");

        GenJnlLine."Bal. Account Type" := GenJnlBatch."Bal. Account Type";
        GenJnlLine.VALIDATE("Bal. Account No.", GenJnlBatch."Bal. Account No.");

        GenJnlLine.Validate(Amount, -_BankCheck.Amount);
        GenJnlLine.Description := COPYSTR(_BankCheck.Description, 1, MAXSTRLEN(GenJnlLine.Description));
        GenJnlLine."External Document No." := _BankCheck."Bank Check No.";

        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        // "Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine."Posting No. Series" := GenJnlBatch."Posting No. Series";
        GenJnlLine."System-Created Entry" := true;


        GenJnlLine.UpdateJournalBatchID();
        GenJnlLine.Insert(true);
    end;


    local procedure PostedBankCheckExist(BankCheckNo: Code[35]): Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("External Document No.");
        GLEntry.SetRange("External Document No.", BankCheckNo);
        exit(not GLEntry.IsEmpty);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        msgBankCheckNoExist: TextConst ENU = 'Bank Check No = %1 Exist!', RUS = 'Банковский Чек Но = %1 существует!';
}