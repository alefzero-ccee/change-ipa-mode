#!/bin/bash
# Criado por Alexandre Marcelo

export LANG=C.UTF-8
export ADM_USER=${1}
export AUTH_TYPE=${2,,}
export USER_FILE=${3}
echo

usage() {
    echo "$0 muda o perfil de autenticação do usuário."
    echo
    echo "Uso: $0 usuarioAdministrativo otp|password arquivoComUsuarios"
    echo ""
    echo
  
}

if [ -z "${ADM_USER}" ] || [ -z "${AUTH_TYPE}" ] || [ -z "${USER_FILE}" ]
then
    usage
    exit 1
fi

if [ "${AUTH_TYPE}" != 'otp' ] && [ "${AUTH_TYPE}" != 'password' ]
then
    echo "Método de autenticação não é válido: \"${AUTH_TYPE}\". Use escolha um dos métodos: [otp|password]"
    echo
    exit 2
fi

if [ ! -f "${USER_FILE}" ]
then
    echo "O arquivo \"${USER_FILE}\" não encontrado."
    echo "Indique um arquivo texto com usuários a serem processados, um usuário por linha."
    echo
    exit 3
fi

echo "Realizando a autenticação do usuário administrativo: ${ADM_USER}"

if ! kinit $ADM_USER 
then 
    echo "Erro ao autenticar o usuário ${ADM_USER}."
    echo
    exit 5
fi

echo
echo "O log das alterações pode ser verificado em ipa.log."
echo "Processando os usuários..."
echo
echo "" > ipa.log
for USER in $(cat $USER_FILE)
do
    printf "Ajustando o usuário $USER... " | tee -a ipa.log
    RESULT=$(ipa user_mod $USER --user-auth-type=$AUTH_TYPE 2>&1 | tee -a ipa.log) 
    printf "Resultado: ${RESULT}"
    echo
done

kdestroy

echo
echo
