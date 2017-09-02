
open class BaseError {
	val message: String
	val cause: String

	public constructor(message: String, cause: String) {
		this.message = message
		this.cause = cause
	}
}

val error = BaseError(message = "message", cause = "a cause")
