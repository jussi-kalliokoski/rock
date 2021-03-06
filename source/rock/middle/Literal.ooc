import ../frontend/Token
import Expression, Node
import tinker/[Resolver, Response, Trail]

Literal: abstract class extends Expression {

    init: func (.token) { super(token) }

    hasSideEffects : func -> Bool { false }

    replace: func (oldie, kiddo: Node) -> Bool { false }

    isResolved: func -> Bool { getType() isResolved() }

    resolve: func (trail: Trail, res: Resolver) -> Response {

        if(!getType() isResolved()) {
            response := getType() resolve(trail, res)
            if(!response ok()) return response
        }

        return Response OK

    }

}
