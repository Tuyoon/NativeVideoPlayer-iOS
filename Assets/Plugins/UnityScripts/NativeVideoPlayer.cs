using UnityEngine;
using UnityEngine.UI;

public class NativeVideoPlayer : SingletonGameObject <NativeVideoPlayer> {

	void Awake()
	{
		Init ();
	}

	public bool Init() 
	{
		return videoPlayerInit();
	}
	
	public bool Load(string filename) 
	{
		return videoPlayerLoad(filename);
	}
	
	public bool Play(RectTransform rTransform)
	{
		CanvasScaler canvasScaler = rTransform.GetComponentInParent<CanvasScaler>();

		Vector2 referenceResolution = canvasScaler.referenceResolution;
		Vector2 currentResolution = new Vector2 (Screen.width, Screen.height);
		Vector2 scale = new Vector2(referenceResolution.x / currentResolution.x, referenceResolution.y / currentResolution.y);

		Vector2 anchoredPosition = Vector2.zero;
		RectTransform rt = rTransform;
		RectTransform tt = canvasScaler.GetComponent<RectTransform> ();
		while (rt != tt) {
			anchoredPosition += rt.anchoredPosition;
			rt = rt.transform.parent.GetComponent<RectTransform>();
		}

		Vector2 size = rTransform.rect.size;
		Rect rect = rTransform.rect;

		anchoredPosition.x = referenceResolution.x / 2 + anchoredPosition.x;
		anchoredPosition.y = referenceResolution.y / 2 - anchoredPosition.y;

		anchoredPosition.x += rTransform.sizeDelta.x/2;
		anchoredPosition.y += rTransform.sizeDelta.y/2;
		anchoredPosition.y += size.y / 2;

		anchoredPosition.x += rect.x;
		anchoredPosition.y += rect.y;

		size.x /= scale.x;
		size.y /= scale.y;
		
		anchoredPosition.x /= scale.x;
		anchoredPosition.y /= scale.y;
		string rectString = anchoredPosition.x + "," + anchoredPosition.y + "," + size.x + "," + size.y;

		return videoPlayerPlay(rectString);
	}

#if !UNITY_EDITOR
	#if UNITY_IPHONE
	private IntPtr mVideoPlayerPtr = IntPtr.Zero;
	
	[DllImport("__Internal")]
	private static extern IntPtr videoPlayerInitIOS();

	[DllImport("__Internal")]
	private static extern bool videoPlayerLoadIOS(IntPtr videoPlayerPtr, string filename);
	
	[DllImport("__Internal")]
	private static extern bool videoPlayerPlayIOS(IntPtr videoPlayerPtr, string rectString);

	private bool videoPlayerInit()
	{
		mVideoPlayerPtr = videoPlayerInitIOS();
		return mVideoPlayerPtr != IntPtr.Zero;
	}
	
	private bool videoPlayerLoad(string filename)
	{
		return videoPlayerLoadIOS(mVideoPlayerPtr, filename);
	}

	private bool videoPlayerPlay(string rectString)
	{
		return videoPlayerPlayIOS(mVideoPlayerPtr, rectString);
	}

	#endif
#else
	bool videoPlayerInit() { return false; }
	
	bool videoPlayerLoad(string filename) { return false; }

	bool videoPlayerPlay(string rectString) { return false; }
#endif

}

