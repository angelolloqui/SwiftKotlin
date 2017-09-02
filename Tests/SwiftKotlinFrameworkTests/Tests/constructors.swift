
open class BaseError {
	let message: String
	let cause: String

	public init(message: String, cause: String) {
		self.message = message
		self.cause = cause
	}
}

let error = BaseError(message: "message", cause: "a cause")
