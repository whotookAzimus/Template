-- This is an example on how to use the type builder, if you don't feel like using sophisticated types in your project (which is bad, you should definitely use types, they are not that hard) you can delete the folder and the buildType.py

export type Profile<T> = {
	Data: T & JSONAcceptable,
	LastSavedData: T & JSONAcceptable,
	FirstSessionTime: number,
	SessionLoadCount: number,
	Session: { PlaceId: number, JobId: string }?,
	RobloxMetaData: JSONAcceptable,
	UserIds: { number },
	KeyInfo: DataStoreKeyInfo,
	OnSave: { Connect: (self: any, listener: () -> ()) -> { Disconnect: (self: any) -> () } },
	OnLastSave: {
		Connect: (
			self: any,
			listener: (reason: "Manual" | "External" | "Shutdown") -> ()
		) -> { Disconnect: (self: any) -> () },
	},
	OnSessionEnd: { Connect: (self: any, listener: () -> ()) -> { Disconnect: (self: any) -> () } },
	OnAfterSave: {
		Connect: (self: any, listener: (last_saved_data: T & JSONAcceptable) -> ()) -> { Disconnect: (self: any) -> () },
	},
	ProfileStore: JSONAcceptable,
	Key: string,

	IsActive: (self: any) -> boolean,
	Reconcile: (self: any) -> (),
	EndSession: (self: any) -> (),
	AddUserId: (self: any, user_id: number) -> (),
	RemoveUserId: (self: any, user_id: number) -> (),
	MessageHandler: (self: any, fn: (message: JSONAcceptable, processed: () -> ()) -> ()) -> (),
	Save: (self: any) -> (),
	SetAsync: (self: any) -> (),
}

export type Janitor = typeof(setmetatable(
	{} :: {
		CurrentlyCleaning: boolean,
		SuppressInstanceReDestroy: boolean,
		UnsafeThreadCleanup: boolean,

		Add: <T>(self: Janitor, object: T, methodName: BooleanOrString?, index: any?) -> T,
		AddObject: <T, A...>(
			self: Janitor,
			constructor: { new: (A...) -> T },
			methodName: BooleanOrString?,
			index: any?,
			A...
		) -> T,

		Remove: (self: Janitor, index: any) -> Janitor,
		RemoveNoClean: (self: Janitor, index: any) -> Janitor,

		RemoveList: (self: Janitor, ...any) -> Janitor,
		RemoveListNoClean: (self: Janitor, ...any) -> Janitor,

		Get: (self: Janitor, index: any) -> any?,
		GetAll: (self: Janitor) -> { [any]: any },

		Cleanup: (self: Janitor) -> (),
		Destroy: (self: Janitor) -> (),

		LinkToInstance: (self: Janitor, Object: Instance, allowMultiple: boolean?) -> RBXScriptConnection,
		LinkToInstances: (self: Janitor, ...Instance) -> Janitor,
	},
	{} :: { __call: (self: Janitor) -> () }
))

export type Signal<T...> = {
	RBXScriptConnection: RBXScriptConnection?,

	Connect: <U...>(self: Signal<T...>, fn: (...any) -> (), U...) -> Connection<U...>,
	Once: <U...>(self: Signal<T...>, fn: (...any) -> (), U...) -> Connection<U...>,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

export type Shake = {
	Amplitude: number,
	Frequency: number,
	FadeInTime: number,
	FadeOutTime: number,
	SustainTime: number,
	Sustain: boolean,
	PositionInfluence: Vector3,
	RotationInfluence: Vector3,
	TimeFunction: () -> number,

	Start: (self: Shake) -> (),
	Stop: (self: Shake) -> (),
	IsShaking: (self: Shake) -> boolean,
	StopSustain: (self: Shake) -> (),
	Update: (self: Shake) -> (Vector3, Vector3, boolean),
	OnSignal: (
		self: Shake,
		signal: RBXScriptSignal,
		callback: (Vector3, Vector3, boolean) -> ()
	) -> RBXScriptConnection,
	BindToRenderStep: (self: Shake, name: string, priority: number, callback: (Vector3, Vector3, boolean) -> ()) -> (),
	Clone: (self: Shake) -> Shake,
	Destroy: (self: Shake) -> (),
}

export type Promise = {
	andThen: (self: Promise, successHandler: (...any) -> ...any, failureHandler: ((...any) -> ...any)?) -> Promise,
	andThenCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> any,
	andThenReturn: (self: Promise, ...any) -> Promise,

	await: (self: Promise) -> (boolean, ...any),
	awaitStatus: (self: Promise) -> (Status, ...any),

	cancel: (self: Promise) -> (),
	catch: (self: Promise, failureHandler: (...any) -> ...any) -> Promise,
	expect: (self: Promise) -> ...any,

	finally: (self: Promise, finallyHandler: (status: Status) -> ...any) -> Promise,
	finallyCall: <TArgs...>(self: Promise, callback: (TArgs...) -> ...any, TArgs...) -> Promise,
	finallyReturn: (self: Promise, ...any) -> Promise,

	getStatus: (self: Promise) -> Status,
	now: (self: Promise, rejectionValue: any?) -> Promise,
	tap: (self: Promise, tapHandler: (...any) -> ...any) -> Promise,
	timeout: (self: Promise, seconds: number, rejectionValue: any?) -> Promise,
}

type Connection<U...> = {
	Connected: boolean,

	Disconnect: (self: Connection<U...>) -> (),
	Reconnect: (self: Connection<U...>) -> (),
}

type JSONAcceptable = { JSONAcceptable } | { [string]: JSONAcceptable } | number | string | boolean | buffer
type Status = "Started" | "Resolved" | "Rejected" | "Cancelled"
type BooleanOrString = boolean | string
type ErrorKind = "ExecutionError" | "AlreadyCancelled" | "NotResolvedInTime" | "TimedOut"

type ErrorStaticAndShared = {
	Kind: {
		ExecutionError: "ExecutionError",
		AlreadyCancelled: "AlreadyCancelled",
		NotResolvedInTime: "NotResolvedInTime",
		TimedOut: "TimedOut",
	},
}
type ErrorOptions = {
	error: string,
	trace: string?,
	context: string?,
	kind: ErrorKind,
}

type Error = typeof(setmetatable(
	{} :: ErrorStaticAndShared & {
		error: string,
		trace: string?,
		context: string?,
		kind: ErrorKind,
		parent: Error?,
		createdTick: number,
		createdTrace: string,

		extend: (self: Error, options: ErrorOptions?) -> Error,
		getErrorChain: (self: Error) -> { Error },
	},
	{} :: { __tostring: (self: Error) -> string }
))

type ErrorStatic = ErrorStaticAndShared & {
	new: (options: ErrorOptions?, parent: Error?) -> Error,
	is: (anything: any) -> boolean,
	isKind: (anything: any, kind: ErrorKind) -> boolean,
}

return {}
