package cn.apppk.books.flutterchess;

public class CChessEngine {

    static {
        System.loadLibrary("engine");
    }

    public native int startup();

    public native int send(String arguments);

    public native String read();

    public native int shutdown();

    public native boolean isReady();

    public native boolean isThinking();
}