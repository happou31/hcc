#include "codegen.h"

#include <stdio.h>

Map *identifiers;
Vector *code;

void initial(FILE *fp)
{
    fprintf(fp, ".intel_syntax noprefix\n");
    fprintf(fp, ".global main\n");
    fprintf(fp, "main: \n");
}

void prologue(FILE *fp)
{
    // プロローグ
    // リターンアドレスをスタックに push し、ベースポインタの指すアドレスをスタックの先頭が指すアドレスとする
    fprintf(fp, "    push rbp\n");
    fprintf(fp, "    mov rbp, rsp\n");
    fprintf(fp, "    sub rsp, %ld\n", identifiers->len * VAR_SIZE); // 変数はすべてVAR_SIZEとしておく
}

void gen_lvalue(FILE *fp, Node *node)
{
    if (node->type != ND_IDENT)
    {
        error("代入の左辺値が変数ではありません。");
    }
    int ident_index = (int)read_map(identifiers, node->name);
    int offset = ident_index * VAR_SIZE;
    fprintf(fp, "    mov rax, rbp\n");
    fprintf(fp, "    sub rax, %d\n", offset);
    fprintf(fp, "    push rax\n");
}

void gen(FILE *fp, Node *node)
{

    if (node->type == ND_RETURN)
    {
        gen(fp, node->lhs);
        fprintf(fp, "    pop rax\n");
        fprintf(fp, "    mov rsp, rbp\n");
        fprintf(fp, "    pop rbp\n");
        fprintf(fp, "    ret\n");
        return;
    }

    if (node->type == ND_NUM)
    {
        fprintf(fp, "    push %d\n", node->value);
        return;
    }

    if (node->type == ND_IDENT)
    {
        gen_lvalue(fp, node);
        fprintf(fp, "    pop rax\n");
        fprintf(fp, "    mov rax, [rax]\n");
        fprintf(fp, "    push rax\n");
        return;
    }

    if (node->type == '=')
    {
        gen_lvalue(fp, node->lhs);
        gen(fp, node->rhs);

        fprintf(fp, "    pop rdi\n");
        fprintf(fp, "    pop rax\n");
        fprintf(fp, "    mov [rax], rdi\n");
        fprintf(fp, "    push rdi\n");
        return;
    }

    gen(fp, node->lhs);
    gen(fp, node->rhs);

    fprintf(fp, "    pop rdi\n");
    fprintf(fp, "    pop rax\n");

    switch (node->type)
    {
    case '+':
        fprintf(fp, "    add rax, rdi\n");
        break;
    case '-':
        fprintf(fp, "    sub rax, rdi\n");
        break;
    case '*':
        fprintf(fp, "    mul rdi\n");
        break;
    case '/':
        fprintf(fp, "    mov rdx, 0\n");
        fprintf(fp, "    div rdi\n");
        break;
    case ND_EQ:
        fprintf(fp, "    cmp rdx, rdi\n");
        fprintf(fp, "    sete al\n");
        fprintf(fp, "    movzb rax, al\n");
        break;
    case ND_NE:
        fprintf(fp, "    cmp rdx, rdi\n");
        fprintf(fp, "    setne al\n");
        fprintf(fp, "    movzb rax, al\n");
        break;
    case ND_LE:
        fprintf(fp, "    cmp rdx, rdi\n");
        fprintf(fp, "    setle al\n");
        fprintf(fp, "    movzb rax, al\n");
        break;
    case ND_LT:
        fprintf(fp, "   cmp rdx, rdi\n");
        fprintf(fp, "   setl al\n");
        fprintf(fp, "   movzb rax, al\n");
        break;
    default:
        break;
    }

    fprintf(fp, "    push rax\n");
}

void epilogue(FILE *fp)
{
    // エピローグ

    printf("    mov rsp, rbp\n");
    printf("    pop rbp\n");
    // rax に演算結果が残っているので、それがこのプログラムの出力になる
    printf("    ret\n");
}

void codegen(FILE *fp, ParseResult *parse_result)
{
    code = parse_result->code;
    identifiers = parse_result->identifiers;
    initial(fp);

    prologue(fp);

    for (int i = 0; i < code->len; ++i)
    {
        // 抽象構文木からアセンブラを生成
        gen(fp, code->data[i]);

        // スタックに式の評価結果が乗っているので pop しておく
        fprintf(fp, "    pop rax\n");
    }

    epilogue(fp);
}