һ��������ּ
  PBox ��һ������ DLL ��ģ�黯����ƽ̨��
  ���ž������޸�ԭ�й���Դ�����ԭ��
  Delphi10.3��WIN10X64 �¿�����
  WIN7X64��WIN10X64�²���ͨ����


����ʹ�÷���
  1��Delphi ԭ�����ļ����޸�Ϊ DLL ���̡�����ض������Ϳ����ˡ��ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˡ�
  ʾ����Module\SysSPath
  Delphi ����������
    type
      { ֧�ֵ��ļ����� }
      TSPFileType = (ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE);

    procedure db_ShowDllForm_Plugins(var frm: TFormClass; var ft: TSPFileType; var strParentModuleName, strSubModuleName, strClassName, strWindowName, strIconFileName: PAnsiChar; const bShow: Boolean = True); stdcall;

  2��VC ԭ���̱��ֲ��䣬����õ� EXE�� �½�һ�� .CPP �ļ������룬��ԭ���ı��� EXE ������ OBJ �ļ����������ӣ��õ� DLL �ļ������õ� plugins Ŀ¼�¾Ϳ����ˡ�
  ʾ��1��DOC\VC\Dialog\7zip
  ʾ��2��DOC\VC\Dialog\Notepad2
  VC ����������
    enum TSPFileType {ftDelphiDll, ftVCDialogDll, ftVCMFCDll, ftQTDll, ftEXE};
    extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(void** frm, TSPFileType* spFileType, char** strParentModuleName, char** strSubModuleName, char** strClassName, char** strWindowName, char** strIconFileName, const bool show = true)


�����������˵��
  DLL �����������˵����
    frm                 ��Delphi ר�á� Delphi �� DLL ������������VC �ÿգ�
    ft                  ���� DLL �����ͣ� ֧�֣�DelphiDll, VCDialogDll, VCMFCDll, QTDll, ftEXE��
    strParentModuleName ����ģ�����ƣ�
    strSubModuleName    ����ģ�����ƣ�
    strClassName        ��VC ר�ã�VC DLL ������������    Delphi �ÿգ�
    strWindowName       ��VC ר�ã�VC DLL ������������ƣ�Delphi �ÿգ�
    strIconFileName     ��ͼ���ļ�����Ϊ�գ��������У�ѡ��ͼ�ꣻ
    bShow               ���Ƿ���ʾ����һ�ε��� VC DLL ʱ���ǲ��ô������� DLL ����ģ�ֻ��Ϊ�˻�ȡ������
  
  
�ģ���ɫ����
  ����֧�֣��˵���ʽ��ʾ����ť���Ի��򣩷�ʽ��ʾ���б��ӷ�ʽ��ʾ��
  PBox ��֧�ֽ�һ�� EXE ��ʾ�ڴ����С�


�壺������������
  ������ݿ�֧�֣����ڱ��˶����ݿⲻ��Ϥ�����Կ���������
  ��� VC(MFC)/QT DLL �����֧�֣�