pageextension 61500 FBM_GLsetupExt_DF extends "General Ledger Setup"
{
    actions
    {
        addlast(processing)
        {
            action("Data Migration")
            {
                Image = Database;
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    cu: codeunit FBM_Migration_DF;
                begin
                    cu.dataMigration();
                end;

            }
            action("Only Site")
            {
                Image = Database;
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    cu: codeunit FBM_Migration_DF;
                begin
                    cu.dataMigrationonlysite();
                end;

            }


        }

    }
}