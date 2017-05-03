

open class BaseError
{
	let message: String
	let cause: String

	public init(message: String, cause: String)
	{
		self.message = message
		self.cause = cause
	}
}

open class SomeError : BaseError
{


	public convenience init()
	{
		self.init(message: "hello")
	}

	public init(message: String)
	{
		super.init(message: message, cause: "")
	}

	public init(_ anonparam: Int)
	{
		super.init(message: "\(anonparam)", cause: "")
	}

}

public func someFunc(_ foo: String)
{
	print("ok: \(foo)")
}
