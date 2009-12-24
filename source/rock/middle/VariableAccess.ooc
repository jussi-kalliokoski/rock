import ../frontend/Token
import Visitor, Expression, VariableDecl, Declaration, Type, Node
import tinker/[Resolver, Response, Trail]

VariableAccess: class extends Expression {

    expr: Expression
    name: String
    
    ref: Declaration
    
    init: func ~variableAccess (.name, .token) {
        this(null, name, token)
    }
    
    init: func ~variableAccessWithExpr (=expr, =name, .token) {
        super(token)
    }
    
    init: func ~varDecl (varDecl: VariableDecl, .token) {
        super(token)
        name = varDecl getName()
        ref = varDecl
    }
    
    init: func ~typeAccess (type: Type, .token) {
        super(token)
        name = type getName()
        ref = type getRef()
    }
    
    accept: func (visitor: Visitor) {
        visitor visitVariableAccess(this)
    }
    
    suggest: func (candidate: VariableDecl) -> Bool {
        // if we're accessing a member, we're expecting the candidate
        // to belong to a TypeDecl..
        if((expr != null) && (candidate owner == null)) {
            //printf("%s is no fit!, we need something to fit %s\n", candidate toString(), toString())
            return false
        }
        
        ref = candidate
        return true
    }
    
    resolve: func (trail: Trail, res: Resolver) -> Response {
        
        if(expr) {
            trail push(this)
            response := expr resolve(trail, res)
            trail pop(this)
            if(!response ok()) return response
            //printf("Resolved expr, type = %s\n", expr getType() ? expr getType() toString() : "(nil)")
        }
        
        /*
         * Try to resolve the access from the expr
         */
        if(!ref && expr) {
            exprType := expr getType()
            //printf("Null ref and non-null expr (%s), looking in type %s\n", expr toString(), exprType toString())
            typeDecl := exprType getRef()
            if(!typeDecl) {
                printf("     - access to %s%s still not resolved, looping (ref = %s)\n", expr ? (expr toString() + "->") : "", name, ref ? ref toString() : "(nil)")
                return Responses LOOP
            }
            typeDecl resolveAccess(this)
        }
        
        /*
         * Try to resolve the access from the trail
         * 
         * It's far simpler than resolving a function call, we just
         * explore the trail from top to bottom and retain the first match.
         */
        if(!ref && !expr) {
            depth := trail size() - 1
            while(depth >= 0) {
                node := trail get(depth)
                node resolveAccess(this)
                if(ref) break // break on first match
                depth -= 1
            }
        }
        
        if(!ref) {
            printf("     - access to %s%s still not resolved, looping (ref = %s)\n", expr ? (expr toString() + "->") : "", name, ref ? ref toString() : "(nil)")
        }
        
        return ref ? Responses OK : Responses LOOP
        
    }
    
    getType: func -> Type {
        if(!ref) return null
        if(ref instanceOf(Expression)) {
            return ref as Expression getType()
        }
        return null
    }
    
    toString: func -> String {
        name
    }
    
    isReferencable: func -> Bool { true }
    
    replace: func (oldie, kiddo: Node) -> Bool {
        match oldie {
            case expr => expr = kiddo; true
            case => false
        }
    }

}
